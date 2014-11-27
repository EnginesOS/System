#!/usr/local/rvm/rubies/ruby-2.1.1/bin/ruby
require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/ManagedEngine.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "rubygems"
require "git"
require 'fileutils'
require 'json'

class EngineBuilder
  @repoName=nil
  @hostName=nil
  @domainName=nil
  @buildname=nil
  @bluePrint=Hash.new
  @framework=nil
  @workerPorts=Array.new
  @webPort=8000
  @vols=Array.new
  @environments=Array.new
  @runtime=String.new
  @databases= Array.new
  def initialize(repo,host,domain,custom_env,docker_api)
    @hostName=host
    @contName=@hostName
    @domainName=domain
    @repoName=repo
    @buildname = File.basename(repo).sub(/\.git$/,"")
    @workerPorts=Array.new
    @webPort=8000
    @vols=Array.new
    if custom_env.instance_of?(Array) == true
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      @set_environments = Hash.new
    else
      @set_environments = custom_env
      @environments = Array.new
    end
    @runtime=String.new
    @databases= Array.new
    @docker_api = docker_api

    FileUtils.mkdir_p(get_basedir)
    @log_file=  File.new(SysConfig.DeploymentDir + "/build.out", File::CREAT|File::TRUNC|File::RDWR, 0644)
    @err_file=  File.new(SysConfig.DeploymentDir + "/build.err", File::CREAT|File::TRUNC|File::RDWR, 0644)

  end

  def log_exception(e)
    @err_file.puts( e.to_s)
    docker_api.last_error(e.to_s)
    puts(e.to_s)
  end

  def backup_lastbuild
    begin
      dir=get_basedir

      if Dir.exists?(dir)
        backup=dir + ".backup"
        if Dir.exists?(backup)
          FileUtils.rm_rf backup
        end
        FileUtils.mv(dir,backup)
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def bluePrint
    return @bluePrint
  end

  def buildname
    return @buildname
  end

  def add_custom_env
    begin
      envs = @bluePrint["software"]["environment_variables"]
      envivronment = String.new
      @docker_file.puts("#Custom ENV")
      envs.each do |env|
        p env
        name=env["name"]
        name = name.gsub(" ","_")
        value=env["value"]
        ask=env["ask_at_runtime"]

        puts("set_environments")
        p @set_environments
        if ask == true  && @set_environments.key?(name) == true
          value=@set_environments[name]
        end
        @environments.push(EnvironmentVariable.new(name,value,ask))
        puts("ENV " + name + " \"" + value +"\"")
        @docker_file.puts("ENV " + name + " \"" + value +"\"")
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def load_blueprint
    begin
      @log_file.puts("Reading Blueprint")
      blueprint_file_name= get_basedir + "/blueprint.json"
      blueprint_file = File.open(blueprint_file_name,"r")
      blueprint_json_str = blueprint_file.read
      blueprint_file.close

      @bluePrint = JSON.parse(blueprint_json_str)
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clone_repo
    begin
      g = Git.clone(@repoName, @buildname, :path => SysConfig.DeploymentDir)
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def add_db_service(name,flavor) #flavor mysql |pgsql  Needs to be dynamic latter
    begin
      dbname=name #+ "-" + @hostName  - leads to issue with JDBC

      #FIXME need better password and with user set options (perhaps use envionment[dbpass] for this ?
      @docker_file.puts("#Database Env")
      @docker_file.puts("ENV dbname " + dbname)
      @docker_file.puts("ENV dbhost " + SysConfig.DBHost)
      @docker_file.puts("ENV dbuser " + name)
      @docker_file.puts("ENV dbpasswd " + name)
      @docker_file.puts("ENV dbflavor " + flavor)
      db = DatabaseService.new(@hostName,dbname,SysConfig.DBHost,name,name,flavor)
      @databases.push(db)

      create_database_service db
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_database_service db
    begin
      db_server_name=db.flavor + "_server"
      db_service = EnginesOSapi.loadManagedService(db_server_name, @docker_api)
      if db_service.is_a?(DBManagedService)

        db_service.add_consumer(db)
        return true
      else
        p db_service
        p db_service.result_mesg
        return false
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def add_file_service(name,dest)
    begin

      permissions = PermissionRights.new(@contName,"","")
      vol=Volume.new(name,SysConfig.LocalFSVolHome + "/" + @contName + "/" + name,dest,"rw",permissions)
      @vols.push(vol)

      @docker_file.puts("#FS Env")
      @docker_file.puts("ENV VOLDIR " + name)
      @docker_file.puts("ENV CONTFSVolHome /home/fs" )# + vol.remotepath) #not nesscessary the same as dest used in constructor
      @docker_file.puts("RUN mkdir -p $CONTFSVolHome")

      create_file_service vol
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_file_service vol
    begin
      vol_service = EnginesOSapi.loadManagedService("volmanager", @docker_api)
      if vol_service.is_a?(EnginesOSapiResult) == false
        vol_service.add_consumer(vol)
        return true
      else
        p vol_service
        p vol_service.result_mesg
        return false
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end

  end

  def create_workers
    begin
      @log_file.puts("Creating Workers")
      commands = Array.new
      workers =@bluePrint["software"]["worker_commands"]
      scripts_path = get_basedir + "/home/engines/scripts/"

      workers.each do |worker|
        commands.push(worker["command"])
      end

      if Dir.exists?(scripts_path) == false
        FileUtils.mkdir_p(scripts_path)
      end

      if commands.length >0
        cmdf= File.open( scripts_path + "pre-running.sh","w")
        if !cmdf
          puts("failed to open " + scripts_path + "pre-running.sh")
          exit
        end
        cmdf.chmod(0755)
        cmdf.puts("#!/bin/bash")
        cmdf.puts("cd /home/app")
        commands.each do |command|
          cmdf.puts(command)
        end
        cmdf.close

      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_work_ports
    begin
      @log_file.puts("Creating work Ports")
      ports =  @bluePrint["software"]["work_ports"]
      puts("Ports Json" + ports.to_s)
      if ports != nil
        ports.each do |port|
          portnum = port["port"]
          name = port["name"]
          external = port['external']
          type = port['protocol']
          if type == nil
            type='tcp'
          end
          #FIX ME when public ports supported
          puts "Port " + portnum.to_s + ":" + external.to_s
          @workerPorts.push(WorkPort.new(name,portnum,external,false,type))
        end

      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def copy_templates

    if copy_base_faults == false
      return false
    else
      return copy_framework_defaults
    end
  end

  def create_presettings_env
    begin
      @log_file.puts("Configuring install Environment")
      archives = @bluePrint["software"]["installedpackages"]
      n=0
      srcs=String.new
      names=String.new
      locations=String.new
      extracts=String.new
      dirs=String.new

      dockerfile = File.open( get_basedir + "/Dockerfile","a")

      archives.each do |archive|
        arc_src=clean_path(archive["src"])
        arc_name=clean_path(archive["name"])
        arc_loc =clean_path(archive["dest"])
        arc_extract=clean_path(archive[ "extractcmd"])
        arc_dir=clean_path(archive["extractdir"])
        if(n >0)
          srcs = srcs + " "
          names =names + " "
          locations = locations + " "
          extracts =extracts + " "
          dirs =dirs + " "
        end

        #FIXME Need to strip any ../
        if arc_loc == "./"
          arc_loc=""
        elsif arc_loc.end_with?("/")
          arc_loc = arc_loc.chop() #note not String#chop
        end

        if arc_extract == "git"
          dockerfile.puts("WORKDIR /tmp")
          dockerfile.puts("USER $ContUser")
          dockerfile.puts("RUN git clone " + arc_src )
          dockerfile.puts("USER 0  ")
          dockerfile.puts("RUN mv  " + arc_dir + " /home/app" +  arc_loc )
          dockerfile.puts("USER $ContUser")
        else
          dockerfile.puts("WORKDIR /tmp")
          dockerfile.puts("USER $ContUser")
          dockerfile.puts("RUN   wget  \""  + arc_src + "\" 2>&1 > /dev/null" )
          dockerfile.puts("RUN " + arc_extract + " \"" + arc_name + "\"*")
          dockerfile.puts("USER 0  ")
          dockerfile.puts("RUN mv " + arc_dir + " /home/app" +  arc_loc )
          dockerfile.puts("USER $ContUser")

          n=n+1
        end
      end

      dockerfile.close
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def add_cron_jobs
    begin

      cjs =  @bluePrint["software"]["cron_jobs"]
      crons = String.new
      n=0

      cron_file = File.open( get_basedir + "/home/crontab","w")
      cjs.each do |cj|
        cron_file.puts(cj["cronjob"])
        n=n+1
      end
      if crons.length >0
        @docker_file.puts("ENV CRONJOBS YES")
        @docker_file.puts("RUN crontab  $data_uid /home/crontab ")
      end
      cron_file.close

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def chown_home_app
    begin

      @docker_file.puts("USER 0")
      @docker_file.puts("RUN if [ ! -d /home/app ];\\")
      @docker_file.puts("  then \\")
      @docker_file.puts("    mkdir -p /home/app ;\\")
      @docker_file.puts("  fi;\\")
      @docker_file.puts(" chown -R $ContUser /home/app")
      @docker_file.puts("USER $ContUser")

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_sed_strings
    begin
      @log_file.puts("set sed strings")
      seds=@bluePrint["software"]["replacementstrings"]
      if seds == nil || seds.empty? == true
        return
      end

      n=0
      seds.each do |sed|

        file = clean_path(sed["file"])
        dest = clean_path(sed["dest"])
        tmp_file = "/tmp/" + File.basename(file) + "." + n.to_s
        if file.match(/^_TEMPLATES.*/) != nil
          template_file = file.gsub(/^_TEMPLATES/,"")
        else
          template_file = nil
        end

        if  template_file != nil
          src_file = "/home/engines/templates/" +  template_file

        else
          src_file = "/home/app/" +  file
        end
        dest_file = "/home/app/" +  dest
        @docker_file.puts("")
        @docker_file.puts("RUN cat " + src_file + " | sed \"" + sed["sedstr"] + "\" > " + tmp_file + " ;\\")
        @docker_file.puts("     cp " + tmp_file  + " " + dest_file)

        n=n+1
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_file_persistance
    begin
      @log_file.puts("set setup_env")

      confd =  arc_dir=clean_path(@bluePrint["software"]["configuredfile"])
      if confd != nil && confd !=""
        @docker_file.puts("ENV CONFIGURED_FILE " + confd)
      end
      insted =   arc_dir=clean_path(@bluePrint["software"]["toconfigurefile"])
      if insted != nil && insted !=""
        @docker_file.puts("ENV INSTALL_SCRIPT " + insted)
      end

      pcf = String.new
      @docker_file.puts("USER 0")
      pds =   @bluePrint["software"]["persistantdirs"]
      dirs= String.new
      pds.each do |dir|
        path = clean_path(dir["path"])
        link_src = path.sub(/app/,"")
        @docker_file.puts("")
        @docker_file.puts("RUN  \\")
        @docker_file.puts("if [ ! -d /home/" + path + " ];\\")
        @docker_file.puts("  then \\")
        @docker_file.puts("    mkdir -p /home/" + path +" ;\\")
        @docker_file.puts("  fi;\\")
        @docker_file.puts("mv /home/" + path + " $CONTFSVolHome ;\\")
        @docker_file.puts("ln -s $CONTFSVolHome/" + link_src + " /home/" + path)
        pcf=path
        dirs = dirs + " " + path
      end
      if dirs.length >1
        @docker_file.puts("")
        @docker_file.puts("RUN chown -R $data_uid.www-data /home/fs ;\\")
        @docker_file.puts("chmod -R 770 /home/fs")
        @docker_file.puts("ENV PERSISTANT_DIRS \""+dirs+"\"")
      end

      pfs =   @bluePrint["software"]["persistantfiles"]
      files= String.new
      pfs.each do |file|
        path =  arc_dir=clean_path(file["path"])
        pcf=path
        @docker_file.puts("")
        @docker_file.puts("RUN mkdir -p /home/" + File.dirname(path) + ";\\")
        @docker_file.puts("  if [ ! -f /home/" + path + " ];\\")
        @docker_file.puts("    then \\")
        @docker_file.puts("      touch  /home/" + path +";\\")
        @docker_file.puts("    fi;\\")
        @docker_file.puts("  mkdir -p $CONTFSVolHome/" + File.dirname(path))

        link_src = path.sub(/app/,"")
        @docker_file.puts("")
        @docker_file.puts("RUN mv /home/" + path + " $CONTFSVolHome ;\\")
        @docker_file.puts("    ln -s $CONTFSVolHome/" + link_src + " /home/" + path)
        files = files + "\""+ path + "\" "
      end
      if files.length >1
        @docker_file.puts("ENV PERSISTANT_FILES "+files)
      end
      if pcf.length >1
        @docker_file.puts("ENV PERSISTANCE_CONFIGURED_FILE \"" + pcf + "\"")
      end
      @docker_file.puts("")
      if dirs.length >1 || files.length >1
        @docker_file.puts("RUN   chown -R $data_uid.www-data /home/fs ;\\")
        @docker_file.puts("      chmod -R 770 /home/fs")
        @docker_file.puts("VOLUME /home/fs/")
      end

      @docker_file.puts("USER $ContUser")

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_stack_env
    begin
      @log_file.puts("Saving stack Environment")
      @docker_file = File.open(get_basedir + "/Dockerfile","a")
      # stef = File.open(get_basedir + "/home/stack.env","w")
      @docker_file.puts("")
      @docker_file.puts("#Stack Env")
      @docker_file.puts("ENV Memory " + @bluePrint["software"]["requiredmemory"].to_s)
      @docker_file.puts("ENV Hostname " + @hostName)
      @docker_file.puts("ENV Domainname " +  @domainName )
      @docker_file.puts("ENV fqdn " +  @hostName + "." + @domainName )
      @docker_file.puts("ENV FRAMEWORK " +   @framework  )
      @docker_file.puts("ENV RUNTIME "  + @runtime  )
      @docker_file.puts("ENV PORT " +  @webPort.to_s  )
      wports = String.new
      n=0
      @workerPorts.each do |port|
        if n < 0
          wports =wports + " "
        end
        wports = wports + port.port.to_s
        n=n+1
      end
      if wports.length >0
        @docker_file.puts("ENV WorkerPorts " + "\"" + wports +"\"")
      end
      ()
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_rake_list
    begin
      @log_file.puts("set rake list")
      rake_cmds = @bluePrint["software"]["rake_tasks"]
      if rake_cmds == nil
        return
      end

      rake_cmds.each do |rake_cmd|
        rake_action = rake_cmd["action"]
        p rake_action
        if rake_action !=nil
          @docker_file.puts("RUN  /usr/local/rbenv/shims/bundle exec rake " + rake_action )
        end
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def set_write_permissions_recursive
    begin
      @log_file.puts("set permissions recussive")
      recursive_chmods = @bluePrint["software"]["chmod_recursive"]
      if recursive_chmods == nil || recursive_chmods.length == 0
        return
      end

      recursive_chmods.each do |recursive_chmod|
        directory = clean_path(recursive_chmod["directory"])
        #FIXME need to strip any ../ and any preceeding ./
        if directory !=nil
          @docker_file.puts("RUN chmod -R /home/app/" + directory )
        end
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def set_write_permissions_single
    begin
      @log_file.puts("set permissions  single")
      single_chmods = @bluePrint["software"]["chmod_single"]
      if single_chmods == nil || single_chmods.length == 0
        return
      end

      single_chmods.each do |single_chmod|
        directory = clean_path(single_chmod["directory"])
        #FIXME need to strip any ../ and any preceeding ./
        if directory !=nil
          @docker_file.puts("RUN chmod -r /home/app/" + directory )
        end
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_pear_list
    begin
      @log_file.puts("set pear list")
      pear_mods = @bluePrint["software"]["pear_mod"]
      if pear_mods == nil || pear_mods.length == 0
        return
      end

      @docker_file.puts("RUN   wget http://pear.php.net/go-pear.phar;\\")
      @docker_file.puts("  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\")
      @docker_file.puts("  php go-pear.phar")

      pear_mods.each do |pear_mod|
        pear_mods = pear_mods["module"]
        p pear_mod
        if pear_mod !=nil
          @docker_file.puts("RUN  pear install pear_mod " + pear_mod )
        end
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def build_init
    begin
      @log_file.puts("Building Image")
      # cmd="cd " + get_basedir + "; docker build  -t " + @hostName + "/init ."
      cmd="/usr/bin/docker build  -t " + @hostName + "/deploy " +  get_basedir
      puts cmd
      res = run_system(cmd)
      if res != true
        puts "build init failed " + res.to_s
        return res
      end
      return res
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def launch_deploy managed_container
    begin
      retval =  managed_container.create_container
      if retval == false
        puts "Failed to Start Container " +  managed_container.last_error
      end

      return retval
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def copy_base_faults
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def copy_framework_defaults
    @log_file.puts("Copy in default templates")
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" + @framework + "/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def get_framework_logging
    begin
      rmt_log_dir_var_fname=get_basedir + "/home/LOG_DIR"
      if File.exists?(rmt_log_dir_var_fname)
        rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
        rmt_log_dir = rmt_log_dir_varfile.read
      else
        rmt_log_dir="/var/log"
      end
      local_log_dir = SysConfig.SystemLogRoot + "/containers/" + @hostName
      if Dir.exists?(local_log_dir) == false
        Dir.mkdir( local_log_dir)
      end

      return " -v " + local_log_dir + ":" + rmt_log_dir + ":rw "

    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def add_services

    @log_file.puts("Adding services")
    services=@bluePrint["software"]["softwareservices"]
    services.each do |service|
      servicetype=service["servicetype_name"]
      if servicetype == "mysql" || servicetype == "pqsql"
        dbname = service["name"]
        dest = service["dest"]
        if dest =="local" || dest == nil
          add_db_service(dbname,servicetype)
        end
      else if servicetype=="filesystem"
          fsname = clean_path(service["name"])
          dest = clean_path(service["dest"])
          add_file_service(fsname, dest)
        else
          p "Unknown Service " + servicetype
        end
      end
    end
end #FIXME

    def setup_dockerfile
      begin
        @log_file.puts("Writing Dockerfile")
        Dir.mkdir(get_basedir  + "/cron") #FIXME is this needed
        @docker_file = File.open(get_basedir + "/Dockerfile","a")
        ospackages = @bluePrint["software"]["ospackages"]
        packages=String.new
        ospackages.each do |package|
          packages = packages + package["name"] + " "
        end
        if packages.length >1
          @docker_file.puts("\nRUN apt-get install -y " + packages )
        end
        @workerPorts.each do |port|
          @docker_file.puts("EXPOSE " + port.port.to_s)
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end
 

  def getwebport
    @log_file.puts("Setting Web port")
    begin
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("PORT")
          i= line.split('=')
          @webPort= i[1].strip
        end
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def getwebuser
    begin
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("USER")
          i= line.split('=')
          @webUser= i[1].strip
        end
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def read_values
    @log_file.puts("Reading Settings")
    begin
      @framework = @bluePrint["software"]["swframework_name"]
      @runtime =  @bluePrint["software"]["langauge_name"]
      #   getwebport
      #    #FIXME need to read from framework and not some piece of static code
      #    if @framework.include?("rails")
      #      @webPort=3000
      #    end
      #    if @framework.include?("tomcat")
      #      @webPort=8080
      #    end
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def get_blueprint_from_repo
    puts("Backup last build")
    backup_lastbuild
    puts("Cloning Blueprint")
    clone_repo
  end

  def build_from_blue_print
    get_blueprint_from_repo
    return build_container
  end

  def build_container
    begin
      @log_file.puts("Reading Blueprint")
      if load_blueprint == false
        return false
      elsif read_values == false
        return false
      elsif copy_templates == false
        return false
      end

      @docker_file = File.open( get_basedir + "/Dockerfile","a")

      if add_custom_env == false
        return false
      elsif getwebport == false
        return false
      elsif getwebuser == false
        return false
      elsif create_work_ports == false
        return false
      elsif add_services == false
        return false
      elsif add_cron_jobs == false
        return false
      elsif  create_workers == false
        return false
      elsif  create_stack_env == false
        return false
      elsif   setup_dockerfile == false
        return false
      elsif   create_presettings_env == false
        return false
      elsif  set_container_user == false
        return false
      elsif  chown_home_app   == false
        return false
      elsif  create_sed_strings == false
        return false
      elsif  create_file_persistance == false
        return false
      elsif  insert_framework_frag_in_dockerfile("builder.mid") == false
        return false
      elsif create_rake_list == false
        return false
      elsif create_pear_list == false
        return false
      elsif set_write_permissions_recursive == false
        return false
      elsif set_write_permissions_single == false
        return false
      elsif insert_framework_frag_in_dockerfile("builder.end") == false
        return false
      end

      @docker_file.close

      if  build_init == false
        @log_file.puts("Error Build Init failed")
        return false
      else
        @log_file.puts("creating deploy image")

        mc = create_managed_container()
      end
      return mc
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def set_container_user
    begin
      @log_file.puts("set container user")

      #FIXME needs to by dynamic
      @docker_file.puts("ENV data_gid 11111")
      @docker_file.puts("ENV data_uid 11111")
      @data_uid=11111
      @data_gid=11111

    rescue Exception=>e
      log_execption(e)
      return false
    end
  end

  def insert_framework_frag_in_dockerfile(frag_name)
    begin
      @log_file.puts(frag_name)

      frame_build_docker_frag = File.open(SysConfig.DeploymentTemplates + "/" + @framework + "/Dockerfile." +frag_name)
      builder_frag = frame_build_docker_frag.read
      @docker_file.write(builder_frag)

    rescue Exception=>e
      log_execption(e)
      return false
    end
  end

  def rebuild_managed_container  engine
    @engine  = engine
    if backup_lastbuild == false
      return false
    elsif setup_rebuild == false
      return false
    else
      return build_container
    end
  end

  def setup_rebuild
    begin
      Dir.mkdir(get_basedir)
      blueprint = @docker_api.load_blueprint(@engine)
      statefile= get_basedir + "/blueprint.json"
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.write(blueprint.to_json)
      f.close
    rescue Exception=>e
      log_execption(e)
      return false
    end
  end

  def create_managed_container

    mc = ManagedEngine.new(@hostName,
    @bluePrint["software"]["requiredmemory"].to_s ,
    @hostName,
    @domainName,
    @hostName + "/deploy",
    @vols,
    @webPort,
    @workerPorts,
    @repoName,
    @databases,
    @environments,
    @framework,
    @runtime,
    @docker_api,
    @data_uid,
    @data_gid
    )

    if mc.save_blueprint(@bluePrint) == false
      puts "failed to save blueprint " + @bluePrint.to_s
    end

    mc.set_conf_register_site true # needs some intelligence here for worker only
    mc.set_conf_self_start true
    mc.save_state # no config.yaml throws a no such container so save so others can use
    bp = mc.load_blueprint
    p  bp
    @log_file.puts("Launching")
    #this will fail as no api at this stage
    if mc.docker_api != nil
      if launch_deploy(mc) == false
        @log_file.puts "Failed to Launch"
      end
      @docker_api.run_volume_builder(mc ,@webUser)
      mc.start_container
    end
    return mc
  end

  protected

  def debug(fld)
    puts "ERROR: "
    p fld
  end

  require 'open3'

  def run_system(cmd)
    ret_val=false
    res = String.new
    error_mesg = String.new
    begin
      Open3.popen3( cmd ) do |stdin, stdout, stderr, th|
        line = String.new
        stderr_is_open=true

        begin
          stdout.each { |line|
            #  print line
            line = line.gsub(/\\\"/,"")
            res += line.chop
            @log_file.puts(line)
            if stderr_is_open
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              @log_file.puts(err)
            end
          }
        rescue Errno::EIO
          res += line.chop
          @log_file.puts(line)
          if stderr_is_open
            err  = stderr.read_nonblock(1000)
            error_mesg += err
            @err_file.puts(err)
          end
        rescue  IO::WaitReadable
          retry
        rescue EOFError
          if stdout.closed? == false
            stderr_is_open = false
            retry
          else if  stderr.closed? == true
              return
            else
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              @err_file.puts(err)
              return
            end
          end
        end

        if error_mesg.include?("Error:")
          p "docker_cmd error " + error_mesg
          return false
        end
        return true
      end
    end
  end

  def clean_path(path)
    #FIXME remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any " " or ";" or "&" or "|" etc
    return path
  end

  def get_basedir
    return SysConfig.DeploymentDir + "/" + @buildname
  end
end

