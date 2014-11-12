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
  
  
  def initialize(repo,host,domain,env,docker_api)
    @hostName=host
    @domainName=domain
    @repoName=repo
    @buildname = File.basename(repo).sub(/\.git$/,"")
    @workerPorts=Array.new
    @webPort=8000
    @vols=Array.new  
    @environments=Array.new
    
p env
    env = Hash.new
    #test code
      env["Title"]="User Entered Title"
    @set_environments = env     
    @runtime=String.new
    @databases= Array.new
    @docker_api = docker_api
  end

  def backup_lastbuild
    dir=get_basedir

    if Dir.exists?(dir)
      backup=dir + ".backup"
      if Dir.exists?(backup)
        FileUtils.rm_rf backup
      end
      FileUtils.mv(dir,backup)
    end
  end

  def bluePrint
    return @bluePrint
  end

  def buildname
    return @buildname
  end

  def add_custom_env
    envs = @bluePrint["software"]["environment_variables"]
    envivronment = String.new
    #ef = File.open( get_basedir + "/home/app.env","w")
    ef = File.open( get_basedir + "/Dockerfile","a")
    ef.puts("#Custom ENV")
    envs.each do |env|
      name=env["name"]
      name = name.gsub(" ","_")
      value=env["value"]
      ask=env["ask_at_runtime"]
      @environments.push(EnvironmentVariable.new(name,value,ask))
      if ask == true
          if @set_environments.key?(name) == true
            value=@set_environments[name]
          end
            #else write the default if none set                      
      end
      ef.puts("ENV " + name + " \"" + value +"\"")
      
    end
    ef.close
  end

  def load_blueprint

    blueprint_file_name= get_basedir + "/blueprint.json"
    blueprint_file = File.open(blueprint_file_name,"r")
    blueprint_json_str = blueprint_file.read
    blueprint_file.close

    @bluePrint = JSON.parse(blueprint_json_str)
  end

  def clone_repo
    g = Git.clone(@repoName, @buildname, :path => SysConfig.DeploymentDir)
  end

  def add_db_service(name,flavor) #flavor mysql |pgsql  Needs to be dynamic latter
    dbname=name #+ "-" + @hostName  - leads to issue with JDBC

    dbf = File.open( get_basedir + "/Dockerfile","a")
    #FIXME need better password and with user set options (perhaps use envionment[dbpass] for this ?
    dbf.puts("#Database Env")
    dbf.puts("ENV dbname " + dbname)
    dbf.puts("ENV dbhost " + SysConfig.DBHost)
    dbf.puts("ENV dbuser " + name)
    dbf.puts("ENV dbpasswd " + name)
    dbf.puts("ENV dbflavor " + flavor)
    db = DatabaseService.new(@hostName,dbname,SysConfig.DBHost,name,name,flavor)
    @databases.push(db)

    dbf.close
    create_database_service db
  end

  def create_database_service db
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
  end

  def add_file_service(name,dest)
  
    permissions = PermissionRights.new(@hostName,"","")
    vol=Volume.new(name,SysConfig.LocalFSVolHome + "/" + name,dest,"rw",permissions)
    @vols.push(vol)
    #fsf = File.open( get_basedir + "/home/fs.env","w")
    fsf = File.open( get_basedir + "/Dockerfile","a")
    fsf.puts("#FS Env")
    fsf.puts("ENV VOLDIR " + name)   
    fsf.puts("ENV CONTFSVolHome /home/fs" )# + vol.remotepath) #not nesscessary the same as dest used in constructor
  #  fsf.puts("VOLUME /home/fs/") Dont do this until files are written
    fsf.puts("RUN mkdir -p $CONTFSVolHome")
    #cant happen here as not mounted
   # fsf.puts("RUN chown -R $ContUser.$ContGrp  $CONTFSVolHome")
    fsf.close
    create_file_service vol
  end

  def create_file_service vol
    vol_service = EnginesOSapi.loadManagedService("volmanager", @docker_api)
       if vol_service.is_a?(EnginesOSapiResult) == false
         vol_service.add_consumer(vol)
         return true
       else
         p vol_service
         p vol_service.result_mesg
         return false
       end
    
  end

  def create_workers
    commands = Array.new
    workers =@bluePrint["software"]["worker_commands"]
    workers.each do |worker|
      commands.push(worker["command"])
    end
    if commands.length >0
      cmdf= File.open(get_basedir + "/home/pre-running.sh","w")
      if !cmdf
        puts ("failed to open " + get_basedir + "/home/pre-running.sh")
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
  end

  def create_work_ports

    ports =  @bluePrint["software"]["work_ports"]
    puts("Ports Json" + ports.to_s)
    if ports != nil
      ports.each do |port|
        portnum = port["port"]
        name = port["name"]
        external = port['external']
        type = port['type']
        if type == nil
          type='tcp'
        end
        #FIX ME when public ports supported
        puts "Port " + portnum.to_s + ":" + external.to_s
        @workerPorts.push(WorkPort.new(name,portnum,external,false,type))
      end
    end

  end

  def copy_templates
    copy_base_faults
    copy_framework_defaults
  end

  def create_presettings_env
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
        elsif arc_loc.ends_with("/")
          arc_loc = arc_loc.chop() #note not String#chop 
      end      
      
      if arc_extract == "git"
        dockerfile.puts("WORKDIR /tmp")
        dockerfile.puts("RUN git clone " + arc_src )
        dockerfile.puts("USER 0  ")
        dockerfile.puts("RUN mv  " + arc_dir + " /home/app" +  arc_loc )
        dockerfile.puts("USER $ContUser")
      else
        dockerfile.puts("RUN   wget  \""  + arc_src + "\"" )
        dockerfile.puts("RUN " + arc_extract + " \"" + arc_name + "\*"")
        dockerfile.puts("USER 0  ")
        dockerfile.puts("RUN mv " + arc_dir + " /home/app" +  arc_loc )
        dockerfile.puts("USER $ContUser")
#        srcs = srcs + "\"" + arc_src + "\""
#        names = names + "\"" + arc_name + "\""
#        locations = locations + "\"" + arc_loc + "\""
#        extracts = extracts + "\"" + arc_extract + "\""
#        dirs = dirs + "\"" + arc_dir + "\""
        n=n+1
      end
    end

#    psf = File.open( get_basedir + "/home/presettings.env","w")
#    psf.puts("FRAMEWORK=" + @framework)
#    psf.puts("declare -a ARCHIVES=(" + srcs + ")")
#    psf.puts("declare -a ARCHIVENAMES=(" + names + ")")
#    psf.puts("declare -a ARCHLOCATIONS=(" + locations + ")")
#    psf.puts("declare -a ARCHEXTRACTCMDS=(" + extracts + ")")
#    psf.puts("declare -a ARCHDIRS=(" + dirs + ")")
#    psf.puts("fqdn=" + @hostName + "." + @domainName)
#    psf.close

    dockerfile.close
  end
  
  def add_cron_jobs 
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    cjs =  @bluePrint["software"]["cron_jobs"]
     crons = String.new
     n=0
 
     cron_file = File.open( get_basedir + "/home/crontab","w")   
     cjs.each do |cj| 
       cron_file.puts(cj["cronjob"])     
       n=n+1
     end
     if crons.length >0
       docker_file.puts("ENV CRONJOBS YES")
       docker_file.puts("RUN crontab  $data_uid /home/crontab ")
     end
     cron_file.close
    docker_file.close
  end
  def chown_home_app
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    docker_file.puts("USER 0")
    docker_file.puts("RUN chown -R $ContUser /home/app")
    docker_file.puts("USER $ContUser")

    docker_file.close
  end

  def create_sed_strings

       seds=@bluePrint["software"]["replacementstrings"]
         if seds == nil || seds.empty? == true
           return
         end
       docker_file = File.open( get_basedir + "/Dockerfile","a")
    
       n=0
       seds.each do |sed|
         file = clean_path(sed["file"])
         dest = clean_path(sed["dest"])
         docker_file.puts("RUN cat /home/app/" +  file + " | sed " + sed["sedstr"] + " > /tmp/" + file + "." + n.to_s )
         docker_file.puts("RUN cp /tmp/" + file + "." + n.to_s + " /home/app/" + dest)

         n=n+1
       end
    docker_file.close
  end
  
  def create_setup_env
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    confd =  arc_dir=clean_path(@bluePrint["software"]["configuredfile"])
    if confd != nil && confd !=""
      docker_file.puts("ENV CONFIGURED_FILE " + confd)
    end
    insted =   arc_dir=clean_path(@bluePrint["software"]["toconfigurefile"])
    if insted != nil && insted !=""
      docker_file.puts("ENV INSTALL_SCRIPT " + insted)
    end

#    seds=@bluePrint["software"]["replacementstrings"]
#
#    n=0
#    seds.each do |sed|
#      file = clean_path(sed["file"])
#      dest = clean_path(sed["dest"])
#      suf.puts("RUN cat /home/app/" +  file + " | sed " + sed["sedstr"] + " > /tmp/" + file + "." + n.to_s )
#      suf.puts("RUN cp /tmp/" + file + "." + n.to_s + " /home/app/" + dest)
#      
##      if n >0
##        sedstrs = sedstrs + " "
##        sedtargets = sedtargets + "  "
##        seddsts = seddsts + "  "
##      end
##      sedstrs = sedstrs + "\"" + sed["sedstr"] +"\""
##      sedtargets = sedtargets + "\"" +  sed["file"]+"\""
##      seddsts = seddsts +  "\"" + sed["dest"]+"\""
#      n=n+1
#    end
##    if  sedstrs.length >1
##      suf.puts("declare -a SEDSTRS=(" + sedstrs + ")")
##      suf.puts("declare -a SEDTARGETS=(" + sedtargets + ")")
##      suf.puts("declare -a SEDDSTS=(" + seddsts + ")")
#    end
        
    pcf = String.new
    docker_file.puts("USER 0")
    pds =   @bluePrint["software"]["persistantdirs"]
    dirs= String.new
    pds.each do |dir|
      path = clean_path(dir["path"])
      link_src = path.sub(/app/,"")
      docker_file.puts("RUN  if [ ! -d /home/" + path + " ]; then mkdir -p /home/" + path +" ; fi")
      docker_file.puts("RUN mv /home/" + path + " $CONTFSVolHome ;ln -s $CONTFSVolHome/" + link_src + " /home/" + path)
      pcf=path
      dirs = dirs + " " + path
    end
    if dirs.length >1
      docker_file.puts("RUN chown -R $data_uid.www-data /home/fs ;chmod -R 770 /home/fs")
      docker_file.puts("ENV PERSISTANT_DIRS \""+dirs+"\"")
    end
                                    
    pfs =   @bluePrint["software"]["persistantfiles"]
    files= String.new
    pfs.each do |file|
      path =  arc_dir=clean_path(file["path"])
      pcf=path
      docker_file.puts("RUN mkdir -p /home/" + FILE.dirname(path))
      docker_file.puts("RUN  if [ ! -d /home/" + path + " ]; then touch -p /home/" + path +" ; fi")
      docker_file.puts("RUN mkdir -p $CONTFSVolHome/" + FILE.dirname(path))
        
      link_src = path.sub(/app/,"")
        
      docker_file.puts("RUN mv /home/" + path + " $CONTFSVolHome ; ln -s $CONTFSVolHome/" + link_src + " /home/" + path)
      files = files + "\""+ path + "\" "
    end
    if files.length >1
      docker_file.puts("ENV PERSISTANT_FILES "+files)
    end
    if pcf.length >1
      docker_file.puts("ENV PERSISTANCE_CONFIGURED_FILE \"" + pcf + "\"")
    end       
    
    if dirs.length >1 || files.length >1
      docker_file.puts("RUN chown -R $data_uid.www-data /home/fs ;chmod -R 770 /home/fs")
      docker_file.puts("VOLUME /home/fs/") 
    end
    
    docker_file.puts("USER $ContUser")
    
    docker_file.close
  end

  def create_stack_env
    stef = File.open(get_basedir + "/Dockerfile","a")
   # stef = File.open(get_basedir + "/home/stack.env","w")
    stef.puts("#Stack Env")
    stef.puts("ENV Memory " + @bluePrint["software"]["requiredmemory"].to_s)
    stef.puts("ENV Hostname " + @hostName)
    stef.puts("ENV Domainname " +  @domainName )
    stef.puts("ENV fqdn " +  @hostName + "." + @domainName )
    stef.puts("ENV FRAMEWORK " +   @framework  )
    stef.puts("ENV RUNTIME "  + @runtime  )
    stef.puts("ENV PORT " +  @webPort.to_s  )
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
      stef.puts("ENV WorkerPorts " + "\"" + wports +"\"")
    end
    stef.close()
  end

  def create_rake_list
    rake_cmds = @bluePrint["software"]["rake_task"]
    if rake_cmds == nil || rake_cmds.length == 0
      return
    end
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    rake_cmds.each do |rake_cmd|
      rake_action = rake_cmds["action"]
      p rake_action
      if rake_action !=nil
        docker_file.puts("RUN  /usr/local/rbenv/shims/bundle exec rake " + rake_action )
      end      
    end
    docker_file.close    
  end
  
def set_write_permissions_recursive
   recursive_chmods = @bluePrint["software"]["chmod_recursive"]
   if recursive_chmods == nil || recursive_chmods.length == 0
     return
   end
   docker_file = File.open( get_basedir + "/Dockerfile","a")
  recursive_chmods.each do |recursive_chmod|
     directory = clean_path(recursive_chmod["directory"])
     #FIXME need to strip any ../ and any preceeding ./
     if directory !=nil
       docker_file.puts("RUN chmod -R /home/app/" + directory )
     end    
   end  
  docker_file.close  
 end
 
def set_write_permissions_single
  single_chmods = @bluePrint["software"]["chmod_single"]
   if single_chmods == nil || single_chmods.length == 0
     return
   end
   docker_file = File.open( get_basedir + "/Dockerfile","a")
  single_chmods.each do |single_chmod|
     directory = clean_path(single_chmod["directory"])
     #FIXME need to strip any ../ and any preceeding ./
     if directory !=nil
       docker_file.puts("RUN chmod -r /home/app/" + directory )
     end     
   end
  docker_file.close    
 end
  
  
def create_pear_list
  pear_mods = @bluePrint["software"]["pear_mod"]
  if pear_mods == nil || pear_mods.length == 0
    return
  end
  docker_file = File.open( get_basedir + "/Dockerfile","a")
  docker_file.puts("RUN   wget http://pear.php.net/go-pear.phar;\\")
  docker_file.puts("  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\")
  docker_file.puts("  php go-pear.phar")
   
  
  pear_mods.each do |pear_mod|
    pear_mods = pear_mods["module"]
    p pear_mod
    if pear_mod !=nil
      docker_file.puts("RUN  pear install pear_mod " + pear_mod )
    end    
  end
  docker_file.close
end

  def build_init
   # cmd="cd " + get_basedir + "; docker build  -t " + @hostName + "/init ."
    cmd="cd " + get_basedir + "; docker build  -t " + @hostName + "/deploy ." 
    puts cmd
    res = run_system(cmd)
    if res != true
      puts "build init failed " + res
      return res
    end
    puts res
  end

  def build_setup
    res = run_system(" docker rm setup ")

    volumes=String.new
       @vols.each do |vol|
         volumes +=  " -v " + vol.localpath + "/" + ":/" + vol.remotepath + "/" 
       end   
       logvol =  get_framework_logging
       volumes += logvol
    cmd = "cd " + get_basedir + "; docker run --memory=386m  " + volumes + " " + SysConfig.timeZone_fileMapping + " -v /opt/dl_cache/:/opt/dl_cache/ --name setup -t " + @hostName +  "/init /bin/bash /home/presetup.sh "
   
    res = run_system(cmd)
    
    if res != true
      puts "build setup failed " +res
      return res
    end
    puts res
  end

  def build_deploy
    cmd="docker commit setup " +  @hostName + "/setup"
    puts cmd
    res = run_system(cmd)
      
      if res != true
        puts "commit setup failed " +res
        return res
      end

    run_system("docker rm setup")
    
    volumes=String.new
    @vols.each do |vol|
      volumes +=  " -v " + vol.localpath + "/" + ":/" + vol.remotepath + "/" 
    end   
    logvol =  get_framework_logging
    volumes += logvol
      
    res = run_system("docker rm deploy")
    
    #fixME needs heaps of ram for gcc  (under ubuntu but not debian Why)
    cmd= "cd " + get_basedir + "; docker run --memory=384m  -v /etc/localtime:/etc/localtime:ro --name deploy " + volumes + " -u " + @webUser + " -t " +   @hostName + "/setup /bin/bash /home/_init.sh " # su -s /bin/bash www-data /home/configcontainer.sh"

    res = run_system(cmd)
    if res != true
      puts "build deploy failed " +res
      return res
    end
   
    
    cmd = "docker commit  deploy " + @hostName + "/deploy"
     
    res=run_system(cmd)
    if res != true
      puts "build deploy commit failed " +res
      return res
    end
    run_system("docker rm deploy ")

   # cmd="docker rmi  " + @hostName + "/setup " + @hostName + "/init"
 
    res = run_system(cmd)
    if res != true
      puts "build cleanup failed " +res
      return res
  end
  end
  
  def launch_deploy managed_container
    retval =  managed_container.setup_container
    if retval == false
      puts "Failed to Start Container " +  managed_container.last_error
    end
    
    return retval

  end

  def copy_base_faults
    cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
    system  cmd
  end

  def copy_framework_defaults
    cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" + @framework + "/* "  + get_basedir
    system  cmd
  end

    def get_framework_logging
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
#      log_vol = Volume.new("",local_log_dir,rmt_log_dir,"rw",PermissionRights.new("system","","")) #(name,localpath,remotepath,mapping_permissions,vol_permissions)
#      
#      @vols.push(log_vol)

    end
    
  def add_services
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
  end

  def setup_dockerfile
    Dir.mkdir(get_basedir  + "/cron") #FIXME is this needed
    docker_file = File.open(get_basedir + "/Dockerfile","a")
    ospackages = @bluePrint["software"]["ospackages"]
    packages=String.new
    ospackages.each do |package|
      packages = packages + package["name"] + " "
    end
    if packages.length >1
      docker_file.puts("\nRUN apt-get install -y " + packages )
    end
    @workerPorts.each do |port|
      docker_file.puts("EXPOSE " + port.port.to_s)
    end
    
    

    docker_file.close

  end

  def getwebport
    stef = File.open( get_basedir + "/home/stack.env","r")
    while line=stef.gets do
      if line.include?("PORT")        
        i= line.split('=')
        @webPort= i[1].strip
      end
    end
  end
  
  def getwebuser
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("USER")        
          i= line.split('=')
          @webUser= i[1].strip
        end
      end 
  end
 

  def read_values
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

    puts("Reading Blueprint")
    load_blueprint
    puts("Reading Settings")
    read_values
    puts("Copy in default templates")
    copy_templates
    puts("Setting Web port")
    add_custom_env
    getwebport
    getwebuser
    puts("creating Worker port")
    create_work_ports
    puts("Adding services")
    add_services
    add_cron_jobs
    puts("Configuring Setup Environment")
   
    puts("Configuring Application Environment")
   
  #  puts("Setting up logging")
   # setup_framework_logging?
    
    puts("Creating workers")
    create_workers
    puts("Saving stack Environment")
    create_stack_env

    puts("Writing Dockerfile")
    setup_dockerfile
    puts("Configuring install Environment")
    create_presettings_env

    set_container_user
    chown_home_app  
    create_sed_strings
    create_setup_env
    insert_framework_frag_in_dockerfile("builder.mid")
    

    
    create_rake_list
    
    create_pear_list
    
    set_write_permissions_recursive
    
    set_write_permissions_single
    
    insert_framework_frag_in_dockerfile("builder.end")
    
    puts("Building base")
    build_init
    puts("Running Setup")
    @docker_api.run_volume_builder(@hostName,@webUser)
  #  build_setup
    puts("Building deploy image")
   # build_deploy
    mc = create_managed_container()
    return mc
  end

  def set_container_user
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    #FIXME needs to by dynamic
    docker_file.puts("ENV data_gid 11111")
    docker_file.puts("ENV data_uid 11111")
    @data_uid=11111
    @data_gid=11111
    docker_file.close
        
  end
def insert_framework_frag_in_dockerfile(frag_name)
    docker_file = File.open( get_basedir + "/Dockerfile","a")
    frame_build_docker_frag = File.open(SysConfig.DeploymentTemplates + "/" + @framework + "/Dockerfile." +frag_name)
    builder_frag = frame_build_docker_frag.read
    docker_file.write(builder_frag)
    docker_file.close
  end


  def rebuild_managed_container  engine
    @engine  = engine
    backup_lastbuild
    setup_rebuild

    return build_container
  end

  def setup_rebuild
    #mkdir build dir
    Dir.mkdir(get_basedir)
    blueprint = @docker_api.load_blueprint(@engine)
    statefile= get_basedir + "/blueprint.json"
    f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
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
    #initialize(name,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime)
#    @workerPorts.each do |port|
#      puts(port.name + " " + port.port.to_s + ":" + port.external.to_s)
#    end

   # @databases.each do |db|
      #create_database_service db
    #end

    #@vols.each do |vol|
     # create_file_service vol
    #end

    if mc.save_blueprint(@bluePrint) == false
      puts "failed to save blueprint " + @bluePrint.to_s
    end

    mc.set_conf_register_site true # needs some intelligence here for worker only
    mc.set_conf_self_start true 
    mc.save_state # no config.yaml throws a no such container so save so others can use
    bp = mc.load_blueprint
    p  bp
    puts("Launching")
    #this will fail as no api at this stage
    if mc.docker_api != nil
      if launch_deploy(mc) == false
        puts "Failed to Launch"
      end
      @docker_api.run_volume_builder(@hostName ,@webUser)
      mc.start_container
    end
    return mc
  end

  protected

  def debug(fld)
    puts "ERROR: " 
    p fld
  end
  
    def run_system (cmd)
      debug(cmd)
      cmd = cmd + " 2>&1"
      res= %x<#{cmd}>  
      p res
      #FIXME should be case insensitive The last one is a pure kludge
      #really need to get stderr and stdout separately
      #res.downcase.include?("error") == false &&  too ristrictive (currently 
      if $? == 0 #&& res.downcase.include?("fail") == false && res.downcase.include?("could not resolve hostname") == false && res.downcase.include?("unsuccessful") == false
        #debug( res)
        return true
      else
        debug(res)
        return res
      end           
    end
    
    def clean_path(path)
      #FIXME remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any " " or ";" or "&" or "|" etc
    
      return path
    end
    
  def get_basedir
#  if @buildname.end_with?(".git") == true
#    dir_name = @buildname.sub(/\.git$/,"")
#    end
    return SysConfig.DeploymentDir + "/" + @buildname
  end

end

