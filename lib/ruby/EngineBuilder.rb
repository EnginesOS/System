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
  @hostname=nil
  @domain_name=nil
  @build_name=nil

  attr_reader :last_error,\
  :repoName,\
  :hostname,\
  :domain_name,\
  :build_name
  
  class BuildError < StandardError
    attr_reader :parent_exception,:method_name
    def initialize(parent,method_name)
      @parent_exception = parent      
    end

  end

  class DockerFileBuilder
    def initialize(reader,containername,hostname,domain_name,webport,logfile,errfile)
      @hostname = hostname
      @container_name = containername
      @domain_name = domain_name
      @webPort = webport
      @blueprint_reader = reader
      
      @log_file = logfile
      @err_file = errfile
      @docker_file = File.open( @blueprint_reader.get_basedir + "/Dockerfile","a")
      
      @layer_count=0
    end

   def count_layer
     ++@layer_count
     if @layer_count >75
       raise EngineBuilder.BuildError.new()
     end
   end

    def write_files_for_docker

      write_stack_env
      write_file_service
      write_db_service
      write_cron_jobs
      write_os_packages
      write_apache_modules
      write_app_archives
      write_container_user
      chown_home_app
      write_worker_commands
      write_sed_strings
      write_persistant_dirs
      write_persistant_files
      insert_framework_frag_in_dockerfile("builder.mid")
      write_rake_list
      write_pear_list
      write_write_permissions_single
      write_write_permissions_recursive
      insert_framework_frag_in_dockerfile("builder.end")
      @docker_file.close
      
    end
    def write_apache_modules
      if @blueprint_reader.apache_modules.count <1
        return 
      end
      ap_modules_str = String.new
      @blueprint_reader.apache_modules.each do |ap_module|
        
        ap_modules_str += ap_module + " "       
    end
      @docker_file.puts("RUN a2enmod " + ap_modules_str)
      count_layer()
    end
    def write_environment_variables
      begin

        @blueprint_reader.environments do |env|
          @docker_file.puts("#Custom ENV")
          @docker_file.puts("ENV " + env.name + " \"" + env.value + "\"")
          count_layer
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_persistant_dirs
      begin
        @log_file.puts("set setup_env")
        src_paths = @blueprint_reader.persistant_dirs[:src_paths]
        dest_paths =  @blueprint_reader.persistant_dirs[:dest_paths]
        n=0
        src_paths.each do |link_src|
          path = dest_paths[n]  
          path="/" + path
          @docker_file.puts("")
          @docker_file.puts("RUN  \\")
          @docker_file.puts("if [ ! -d /home/app" + path + " ];\\")
          @docker_file.puts("  then \\")
          @docker_file.puts("    mkdir -p /home/app" + path +" ;\\")
          @docker_file.puts("  fi;\\")
          @docker_file.puts("mv /home/app" + path + " $VOLDIR ;\\")
          @docker_file.puts("ln -s $VOLDIR/" + link_src + " /home/app" + path)
          n=n+1
        count_layer
        end
        if src_paths.length >1
          @docker_file.puts("")
          @docker_file.puts("RUN chown -R $data_uid.www-data /home/fs ;\\")
          @docker_file.puts("chmod -R 770 /home/fs")
          count_layer
        end

      rescue Exception=>e
        log_exception(e)
        return false 
      end
    end

    def write_persistant_files
      begin
        @log_file.puts("set setup_env")
        src_paths = @blueprint_reader.persistant_files[:src_paths]
        dest_paths =  @blueprint_reader.persistant_files[:dest_paths]
        n=0

        src_paths.each do |link_src|
          path = dest_paths[n]
          @docker_file.puts("")
          @docker_file.puts("RUN mkdir -p /home/app/" + File.dirname(path) + ";\\")
          @docker_file.puts("  if [ ! -f /home/app/" + path + " ];\\")
          @docker_file.puts("    then \\")
          @docker_file.puts("      touch  /home/app/" + path +";\\")
          @docker_file.puts("    fi;\\")
          @docker_file.puts("  mkdir -p $VOLDIR/" + File.dirname(path) +";\\")       
          @docker_file.puts("\\")
          @docker_file.puts("   mv /home/app/" + path + " $VOLDIR ;\\")
          @docker_file.puts("    ln -s $VOLDIR/" + link_src + " /home/app/" + path)
        count_layer
        end
    
        @docker_file.puts("")
        @docker_file.puts("USER 0")
      count_layer
        @docker_file.puts("RUN   chown -R $data_uid.www-data /home/fs ;\\")
        @docker_file.puts("      chmod -R 770 /home/fs")
      count_layer
        @docker_file.puts("VOLUME /home/fs/")
      count_layer
        @docker_file.puts("USER $ContUser")
      count_layer
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def  write_file_service
      begin
        @docker_file.puts("#FS Env")
        @docker_file.puts("ENV CONTFSVolHome /home/fs/" )
        count_layer
        @blueprint_reader.volumes.each_value do |vol|
          @docker_file.puts("ENV VOLDIR /home/fs/" + vol.name)
          count_layer
          @docker_file.puts("RUN mkdir -p $CONTFSVolHome/" + vol.name)
          count_layer
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_sed_strings
      begin
        n=0
        @blueprint_reader.sed_strings[:src_file].each do |src_file|
          #src_file = @sed_strings[:src_file][n]
          dest_file = @blueprint_reader.sed_strings[:dest_file][n]
          sed_str =  @blueprint_reader.sed_strings[:sed_str][n]
          tmp_file =  @blueprint_reader.sed_strings[:tmp_file][n]
          @docker_file.puts("")
          @docker_file.puts("RUN cat " + src_file + " | sed \"" + sed_str + "\" > " + tmp_file + " ;\\")
          @docker_file.puts("     cp " + tmp_file  + " " + dest_file)
count_layer
          n=n+1
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_rake_list
      begin
        @blueprint_reader.rake_actions.each do |rake_cmd|
          if rake_cmd !=nil
            @docker_file.puts("RUN  /usr/local/rbenv/shims/bundle exec rake " + rake_cmd )
            count_layer
          end
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_os_packages
      begin
        packages=String.new

        @blueprint_reader.os_packages.each do |package|
          packages = packages + package + " "
        end
        if packages.length >1
          @docker_file.puts("\nRUN apt-get install -y " + packages )
          count_layer
        end

        #FIXME Wrong spot
        @blueprint_reader.workerPorts.each do |port|
          @docker_file.puts("EXPOSE " + port.port.to_s)
          count_layer
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def insert_framework_frag_in_dockerfile(frag_name)
      begin
        @log_file.puts(frag_name)

        frame_build_docker_frag = File.open(SysConfig.DeploymentTemplates + "/" + @blueprint_reader.framework + "/Dockerfile." + frag_name)
        builder_frag = frame_build_docker_frag.read
        @docker_file.write(builder_frag)
        count_layer
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def chown_home_app
      begin

        @docker_file.puts("USER 0")
        count_layer
        @docker_file.puts("RUN if [ ! -d /home/app ];\\")
        @docker_file.puts("  then \\")
        @docker_file.puts("    mkdir -p /home/app ;\\")
        @docker_file.puts("  fi;\\")
        @docker_file.puts(" mkdir -p /home/fs ; mkdir -p /home/fs/local ;\\")
        @docker_file.puts(" chown -R $ContUser /home/app /home/fs /home/fs/local")
        count_layer
        @docker_file.puts("USER $ContUser")
        count_layer

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_worker_commands
      begin
        scripts_path = @blueprint_reader.get_basedir + "/home/engines/scripts/"

        if Dir.exists?(scripts_path) == false
          FileUtils.mkdir_p(scripts_path)
        end

        if @blueprint_reader.worker_commands != nil && @blueprint_reader.worker_commands.length >0
          cmdf= File.open( scripts_path + "pre-running.sh","w")
          if !cmdf
            puts("failed to open " + scripts_path + "pre-running.sh")
            exit
          end
          cmdf.chmod(0755)
          cmdf.puts("#!/bin/bash")
          cmdf.puts("cd /home/app")
          @blueprint_reader.worker_commands.each  do |command|
            cmdf.puts(command)
          end
          cmdf.close
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_cron_jobs
      begin

        if @blueprint_reader.cron_jobs != nil && @blueprint_reader.cron_jobs.length <0

          cron_file = File.open( get_basedir + "/home/crontab","w")
          crons.each do |cj|
            cron_file.puts(cj)

            n=n+1
          end

          if @blueprint_reader.cron_jobs.length >0
            @docker_file.puts("ENV CRONJOBS YES")
            count_layer
            @docker_file.puts("RUN crontab  $data_uid /home/crontab ")
            count_layer
          end
          cron_file.close
        end

        return true

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_db_service
      begin

        @blueprint_reader.databases.each do |db|
          @docker_file.puts("#Database Env")
          @docker_file.puts("ENV dbname " + db.name)
          count_layer
          @docker_file.puts("ENV dbhost " + db.dbHost)
          count_layer
          @docker_file.puts("ENV dbuser " + db.dbUser)
          count_layer
          @docker_file.puts("ENV dbpasswd " + db.dbPass)
          count_layer
          @docker_file.puts("ENV dbflavor " + db.flavor)
          count_layer
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_write_permissions_single
      begin
        if @blueprint_reader.single_chmods == nil
          return
        end
        @blueprint_reader.single_chmods.each do |directory|
          if directory !=nil
            @docker_file.puts("RUN chmod -r /home/app/" + directory )
            count_layer
          end
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_write_permissions_recursive
      begin
        if @blueprint_reader.recursive_chmods == nil
          return
        end
        @blueprint_reader.recursive_chmods.each do |recursive_chmod|
          if directory !=nil
            @docker_file.puts("RUN chmod -R /home/app/" + directory )
            count_layer
          end
        end
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end

    def write_app_archives
      begin

        n=0
        srcs=String.new
        names=String.new
        locations=String.new
        extracts=String.new
        dirs=String.new

        @blueprint_reader.archives_details[:arc_src].each do |archive|
          arc_src=@blueprint_reader.archives_details[:arc_src][n]
          arc_name=@blueprint_reader.archives_details[:arc_name][n]
          arc_loc =@blueprint_reader.archives_details[:arc_loc][n]
          arc_extract=@blueprint_reader.archives_details[:arc_extract][n]
          arc_dir=@blueprint_reader.archives_details[:arc_dir][n]
          if(n >0)
            srcs = srcs + " "
            names =names + " "
            locations = locations + " "
            extracts =extracts + " "
            dirs =dirs + " "
          end

          if arc_loc == "./"
            arc_loc=""
          elsif arc_loc.end_with?("/")
            arc_loc = arc_loc.chop() #note not String#chop
          end

          if arc_extract == "git"
            @docker_file.puts("WORKDIR /tmp")
            count_layer
            @docker_file.puts("USER $ContUser")
            count_layer
            @docker_file.puts("RUN git clone " + arc_src )
            count_layer
            @docker_file.puts("USER 0  ")
            count_layer
            @docker_file.puts("RUN mv  " + arc_dir + " /home/app" +  arc_loc )
            count_layer
            @docker_file.puts("USER $ContUser")
            count_layer
          else
            @docker_file.puts("WORKDIR /tmp")
            count_layer            
            @docker_file.puts("USER $ContUser")
            count_layer
            @docker_file.puts("RUN   wget  \""  + arc_src + "\" 2>&1 > /dev/null ;\\" )
            @docker_file.puts(" " + arc_extract + " \"" + arc_name + "\"* 2>&1 > /dev/null ")
            @docker_file.puts("USER 0  ")
            count_layer
            @docker_file.puts("RUN mv " + arc_dir + " /home/app" +  arc_loc )
            count_layer
            @docker_file.puts("USER $ContUser")
            count_layer

            n=n+1
          end
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end

    end

    def write_container_user
      begin
        @log_file.puts("set container user")

        #FIXME needs to by dynamic

        @docker_file.puts("ENV data_gid " +  @blueprint_reader.data_uid)
        count_layer
        @docker_file.puts("ENV data_uid " + @blueprint_reader.data_gid)
        count_layer

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_stack_env
      begin
        @log_file.puts("Saving stack Environment")

        # stef = File.open(get_basedir + "/home/stack.env","w")
        @docker_file.puts("")
        @docker_file.puts("#Stack Env")
        @docker_file.puts("ENV Memory " + @blueprint_reader.memory.to_s)
        count_layer
        @docker_file.puts("ENV Hostname " + @hostname)
        count_layer
        @docker_file.puts("ENV Domainname " +  @domain_name )
        count_layer
        @docker_file.puts("ENV fqdn " +  @hostname + "." + @domain_name )
        count_layer
        @docker_file.puts("ENV FRAMEWORK " +   @blueprint_reader.framework  )
        count_layer
        @docker_file.puts("ENV RUNTIME "  + @blueprint_reader.runtime  )
        count_layer
        @docker_file.puts("ENV PORT " +  @webPort.to_s  )
        count_layer
        wports = String.new
        n=0
        @blueprint_reader.workerPorts.each do |port|
          if n < 0
            wports =wports + " "
          end
          @docker_file.puts("EXPOSE " + port.port.to_s)
          count_layer
          wports = wports + port.port.to_s
          n=n+1
        end
        if wports.length >0
          @docker_file.puts("ENV WorkerPorts " + "\"" + wports +"\"")
          count_layer
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_pear_list
      if @blueprint_reader.pear_modules.count >0
        @docker_file.puts("RUN   wget http://pear.php.net/go-pear.phar;\\")
        @docker_file.puts("  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\")
        @docker_file.puts("  php go-pear.phar")
        count_layer

        @blueprint_reader.pear_modules.each do |pear_mod|
          if pear_mod !=nil
            @docker_file.puts("RUN  pear install pear_mod " + pear_mod )
            count_layer
          end
        end
      end
    rescue Exception=>e
      log_exception(e)
      return false
    end

    protected
def log_exception(e)
     @err_file.puts( e.to_s)
     puts(e.to_s)
     @last_error=  e.to_s
     e.backtrace.each do |bt |
       p bt
     end
     return false
   end
    ##################### End of
  end

  class BluePrintReader
    def initialize(build_name,contname,blue_print,logfile,errfile)
      @build_name = build_name

      @data_uid="11111"
      @data_gid="11111"

      @container_name = contname
      @log_file=logfile
      @err_file=errfile
      @blueprint = blue_print
    end

    attr_reader :persistant_files,\
    :persistant_dirs,\
    :last_error,\
    :workerPorts,\
    :environments,\
    :recursive_chmods,\
    :single_chmods,\
    :cron_jobs,\
    :framework,\
    :runtime,\
    :memory,\
    :rake_actions,\
    :os_packages,\
    :pear_modules,\
    :archives_details,
    :worker_commands,
    :cron_jobs,\
    :sed_strings,\
    :volumes,\
    :databases,\
    :apache_modules,\
    :data_uid,\
    :data_gid

    def clean_path(path)
      #FIXME remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any " " or ";" or "&" or "|" etc
      return path
    end

    def get_basedir
      return SysConfig.DeploymentDir + "/" + @build_name
    end

    def log_exception(e)
      @err_file.puts( e.to_s)
      puts(e.to_s)
      #@last_error=  e.to_s
      e.backtrace.each do |bt |
        p bt
      end
    end

    def process_blueprint
      begin

        read_rake_list
        read_services
        read_os_packages
        read_lang_fw_values
        read_pear_list
        read_app_packages
        read_apache_modules
        read_write_permissions_recursive
        read_write_permissions_single
        read_worker_commands
        read_cron_jobs
        read_sed_strings
        read_work_ports
        read_os_packages
        read_app_packages
        read_environment_variables
        read_persistant_files
        read_persistant_dirs

      rescue Exception=>e
        log_exception(e)
      end

    end

    def read_persistant_dirs
      begin
        @log_file.puts("set setup_env")

        @persistant_dirs = Hash.new
        src_paths = Array.new
        dest_paths = Array.new

        pds =   @blueprint["software"]["persistantdirs"]

        pds.each do |dir|
          path = clean_path(dir["path"])
          link_src = path.sub(/app/,"")
          src_paths.push(link_src)
          dest_paths.push(path)
        end
        @persistant_dirs[:src_paths]= src_paths
        @persistant_dirs[:dest_paths]= dest_paths
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_persistant_files
      begin
        @log_file.puts("set setup_env")

        @persistant_files = Hash.new
        src_paths = Array.new
        dest_paths = Array.new

        pfs =   @blueprint["software"]["persistantfiles"]
        files= String.new
        pfs.each do |file|
          path =  arc_dir=clean_path(file["path"])
          link_src = path.sub(/app/,"")
          src_paths.push(link_src)
          dest_paths.push(path)
        end

        @persistant_files[:src_paths]= src_paths
        @persistant_files[:dest_paths]= dest_paths

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_rake_list
      begin
        @rake_actions = Array.new
        @log_file.puts("set rake list")
        rake_cmds = @blueprint["software"]["rake_tasks"]
        if rake_cmds == nil
          return
        end

        rake_cmds.each do |rake_cmd|
          rake_action = rake_cmd["action"]
          p rake_action
          if rake_action !=nil
            @rake_actions.push(rake_action)
          end
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_services

      @databases=Array.new
      @volumes=Hash.new

      @log_file.puts("Adding services")
      services=@blueprint["software"]["softwareservices"]
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
       elsif servicetype=="filesystem"
          name = clean_path(service["name"])
          dest = clean_path(service["dest"])
          add_ftp_service(name, dest)
        else
            p "Unknown Service " + servicetype
          end
        end
      end
    end #FIXME

    def add_file_service(name,dest)
      begin
        if dest == nil || dest == ""
          dest=name
        end
        if(dest.start_with?("/home/app/") == false)
          dest="/home/fs/" + dest          
        end
        permissions = PermissionRights.new(@container_name,"","")
        vol=Volume.new(name,SysConfig.LocalFSVolHome + "/" + @container_name + "/" + dest,dest,"rw",permissions)
        @volumes[name]=vol

      rescue Exception=>e
        p name
        p dest
        p @container_name
        log_exception(e)
        return false
      end
    end

    def  add_db_service(dbname,servicetype)

      db = DatabaseService.new(@container_name,dbname,SysConfig.DBHost,dbname,dbname,servicetype)
      @databases.push(db)

    end

    def read_os_packages
      begin
        @os_packages = Array.new

        @log_file.puts("Writing Dockerfile")
        ospackages = @blueprint["software"]["ospackages"]
        ospackages.each do |package|
          @os_packages.push(package["name"])
        end
      rescue
        log_exception(e)
        return false
      end
    end

    def read_lang_fw_values
      @log_file.puts("Reading Settings")
      begin
        @framework = @blueprint["software"]["swframework_name"]
        p @framework
        @runtime =  @blueprint["software"]["langauge_name"]
        @memory =  @blueprint["software"]["requiredmemory"]
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_pear_list
      begin
        @pear_modules = Array.new

        @log_file.puts("set pear list")
        pear_mods = @blueprint["software"]["pear_mod"]
        if pear_mods == nil || pear_mods.length == 0
          return
          pear_mods.each do |pear_mod|
            mod =             pear_mod["module"]
            if mod !=nil
              @pear_modules.push(mod)
            end

          end
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end
    
    def read_apache_modules
      @apache_modules = Array.new
      
      mods =  @blueprint["software"]["apache_modules"]
        if mods == nil
          return true
        end
      mods.each do |ap_module|
        mod = ap_module["module"]
          if mod != nil
            @apache_modules.push(mod)
          end
      end
      return true
      rescue Exception=>e
        log_exception(e)
        return false
      end
      
    def read_app_packages
      begin
        @archives_details = Hash.new
        @archives_details[:arc_src] = Array.new
        @archives_details[:arc_name] = Array.new
        @archives_details[:arc_extract] = Array.new
        @archives_details[:arc_loc] = Array.new
        @archives_details[:arc_dir] = Array.new
        @log_file.puts("Configuring install Environment")
        archives = @blueprint["software"]["installedpackages"]
        n=0
        srcs=String.new
        names=String.new
        locations=String.new
        extracts=String.new
        dirs=String.new

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
          if arc_loc == "./"
            arc_loc=""
          elsif arc_loc.end_with?("/")
            arc_loc = arc_loc.chop() #note not String#chop
          end
          @archives_details[:arc_src].push(arc_src)
          @archives_details[:arc_name].push(arc_name)
          @archives_details[:arc_extract].push(arc_extract)
          @archives_details[:arc_loc].push(arc_loc)
          @archives_details[:arc_dir].push(arc_dir)

        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_write_permissions_recursive
      begin
        @recursive_chmods = Array.new
        @log_file.puts("set permissions recussive")
        chmods = @blueprint["software"]["chmod_recursive"]
        if chmods != nil
          chmods.each do |chmod |
            directory = clean_path(recursive_chmod)
            @recursive_chmods.push(directory)
          end
          #FIXME need to strip any ../ and any preceeding ./
          return
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_write_permissions_single
      begin
        @single_chmods =Array.new
        @log_file.puts("set permissions  single")
        chmods = @blueprint["software"]["chmod_single"]
        if chmods != nil
          chmods.each do | single_chmod |
            directory = clean_path(single_chmod["directory"])
            @single_chmods.push(directory)
          end
        end
        return true

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_worker_commands
      begin
        @log_file.puts("Creating Workers")
        @worker_commands = Array.new
        workers =@blueprint["software"]["worker_commands"]

        workers.each do |worker|
          @worker_commands.push(worker["command"])
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_cron_jobs
      begin

        cjs =  @blueprint["software"]["cron_jobs"]
        @cron_jobs = Array.new
        n=0
        cjs.each do |cj|
          @cron_jobs.push(cj["cronjob"])
        end

        return true

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_sed_strings
      begin
        @sed_strings = Hash.new
        @sed_strings[:src_file] = Array.new
        @sed_strings[:dest_file] = Array.new
        @sed_strings[:sed_str] = Array.new
        @sed_strings[:tmp_file] = Array.new

        @log_file.puts("set sed strings")
        seds=@blueprint["software"]["replacementstrings"]
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
          sedstr = sed["sedstr"]
          @sed_strings[:src_file].push(src_file)
          @sed_strings[:dest_file].push(dest_file)
          @sed_strings[:tmp_file].push(tmp_file)
          @sed_strings[:sed_str].push(sedstr)

          n=n+1
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def read_work_ports
      begin
        @workerPorts = Array.new
        @log_file.puts("Creating work Ports")
        ports =  @blueprint["software"]["work_ports"]
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

    def read_environment_variables
      @environments = Array.new
      begin
        envs = @blueprint["software"]["environment_variables"]
        envs.each do |env|
          p env
          name=env["name"]
          name = name.gsub(" ","_")
          value=env["value"]
          ask=env["ask_at_runtime"]
          if @set_environments != nil
            if ask == true  && @set_environments.key?(name) == true
              value=@set_environments[name]
            end
          end
          @environments.push(EnvironmentVariable.new(name,value,ask))
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end
  end

  def initialize(repo,contname,host,domain,custom_env,core_api)
    @hostname=host
    @container_name=contname
    @domain_name=domain
    @repoName=repo
    @build_name = File.basename(repo).sub(/\.git$/,"")
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
    @core_api = core_api

    begin
      FileUtils.mkdir_p(get_basedir)
      @log_file=  File.new(SysConfig.DeploymentDir + "/build.out", File::CREAT|File::TRUNC|File::RDWR, 0644)
      @err_file=  File.new(SysConfig.DeploymentDir + "/build.err", File::CREAT|File::TRUNC|File::RDWR, 0644)
    rescue
      log_exception(e)
    end
  end



  def setup_framework_logging
    begin
      rmt_log_dir_var_fname=get_basedir + "/home/LOG_DIR"
      if File.exists?(rmt_log_dir_var_fname)
        rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
        rmt_log_dir = rmt_log_dir_varfile.read
      else
        rmt_log_dir="/var/log"
      end
      local_log_dir = SysConfig.SystemLogRoot + "/containers/" + @hostname
      if Dir.exists?(local_log_dir) == false
        Dir.mkdir( local_log_dir)
      end

      return " -v " + local_log_dir + ":" + rmt_log_dir + ":rw "

    rescue Exception=>e
      log_exception(e)
      return false
    end
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
      #throw BuildException.new(e,"backup_lastbuild")
    end
  end

  def load_blueprint
    begin
      @log_file.puts("Reading Blueprint")
      blueprint_file_name= get_basedir + "/blueprint.json"
      blueprint_file = File.open(blueprint_file_name,"r")
      blueprint_json_str = blueprint_file.read
      blueprint_file.close

      # @blueprint = JSON.parse(blueprint_json_str)
      return JSON.parse(blueprint_json_str)
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clone_repo
    begin
      g = Git.clone(@repoName, @build_name, :path => SysConfig.DeploymentDir)
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_database_service db
    begin
      db_server_name=db.flavor + "_server"
      db_service = EnginesOSapi.loadManagedService(db_server_name, @core_api)
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

  def create_file_service vol
    begin
      vol_service = EnginesOSapi.loadManagedService("volmanager", @core_api)
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

  def setup_default_files

    if setup_global_defaults == false
      return false
    else
      return setup_framework_defaults
    end
  end

  def create_db_service(name,flavor)
    begin
      db = DatabaseService.new(@hostname,dbname,SysConfig.DBHost,name,name,flavor)
      databases.push(db)
      create_database_service db
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def build_init
    begin
      @log_file.puts("Building Image")
      # cmd="cd " + get_basedir + "; docker build  -t " + @hostname + "/init ."
      cmd="/usr/bin/docker build  -t " + @hostname + "/deploy " +  get_basedir
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

  def setup_global_defaults
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def setup_framework_defaults
    @log_file.puts("Copy in default templates")
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" +  @blueprint_reader.framework + "/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def get_blueprint_from_repo
    puts("Backup last build")
    if backup_lastbuild == false
      return false
    end
    puts("Cloning Blueprint")
    return clone_repo
  end

  def build_from_blue_print
    if get_blueprint_from_repo == false
      return false
    end
    return build_container
  end

  def read_web_port
    @log_file.puts("Setting Web port")
    begin
      stef = File.open( get_basedir + "/home/stack.env","r")
      while line=stef.gets do
        if line.include?("PORT")
          i= line.split('=')
          @webPort= i[1].strip
          p :web_port_line
          p line
        end
        p @webPort
        puts(@webPort)
      end
    rescue Exception=>e
      log_exception(e)
      #      throw BuildException.new(e,"setting web port")
      return false
    end
  end

  def read_web_user
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

  def build_container
    begin

      @log_file.puts("Reading Blueprint")
      @blueprint = load_blueprint
      if @blueprint == false
        return false
      end

      @blueprint_reader = BluePrintReader.new(@build_name,@container_name,@blueprint,@log_file,@err_file)
      @blueprint_reader.process_blueprint

      if  setup_default_files == false
        return false
      end

      read_web_port
      read_web_user

      dockerfile_builder = DockerFileBuilder.new( @blueprint_reader,@container_name, @hostname,@domain_name,@webPort,@log_file,@err_file)
      dockerfile_builder.write_files_for_docker

      setup_framework_logging

      if  build_init == false
        @log_file.puts("Error Build Init failed")
        return false
      else
        @log_file.puts("creating deploy image")

        @blueprint_reader.databases.each() do |db|
          create_database_service db
        end
        @blueprint_reader.volumes.each_value() do |vol|
          create_file_service vol
        end

        mc = create_managed_container()
      end

      return mc
      
    rescue Exception=>e
      

      log_exception(e)
    rescue Exception=>e
      log_exception(e)
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
      blueprint = @core_api.load_blueprint(@engine)
      statefile= get_basedir + "/blueprint.json"
      f = File.new(statefile,File::CREAT|File::TRUNC|File::RDWR, 0644)
      f.write(blueprint.to_json)
      f.close
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def create_managed_container

    mc = ManagedEngine.new(@hostname,
    @blueprint_reader.memory.to_s ,
    @hostname,
    @domain_name,
    @container_name + "/deploy",
    @blueprint_reader.volumes,
    @webPort,
    @blueprint_reader.workerPorts,
    @repoName,
    @blueprint_reader.databases,
    @blueprint_reader.environments,
    @blueprint_reader.framework,
    @blueprint_reader.runtime,
    @core_api,
    @blueprint_reader.data_uid,
    @blueprint_reader.data_gid
    )

    mc.conf_register_site=( true) # needs some intelligence here for worker only
    mc.conf_self_start= (true)
    mc.save_state # no config.yaml throws a no such container so save so others can use
    if mc.save_blueprint(@blueprint) == false
      puts "failed to save blueprint " + @blueprint.to_s
    end

    bp = mc.load_blueprint
    p  bp
    @log_file.puts("Launching")
    #this will fail as no api at this stage
    if mc.core_api != nil
      if launch_deploy(mc) == false
        @log_file.puts "Failed to Launch"
      end
      @core_api.run_volume_builder(mc ,@webUser)
      #  mc.start_container
    end
    return mc
  end

  protected
def log_exception(e)
  @err_file.puts( e.to_s)
  puts(e.to_s)
  @last_error=  e.to_s
  e.backtrace.each do |bt |
    p bt
  end
end
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
        oline = String.new
        stderr_is_open=true

        begin
          stdout.each { |line|
            #  print line
            line = line.gsub(/\\\"/,"")
            res += line.chop
            oline = line
            @log_file.puts(line)
            if stderr_is_open
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              @log_file.puts(err)
            end
          }
        rescue Errno::EIO
          res += line.chop
          @log_file.puts(oline)
          if stderr_is_open
            err  = stderr.read_nonblock(1000)
            error_mesg += err
            @err_file.puts(err)
            retry
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

  def get_basedir
    return SysConfig.DeploymentDir + "/" + @build_name
  end
end

