require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/ManagedEngine.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "rubygems"
require "git"
require 'fileutils'
require 'json'
require '/opt/engines/lib/ruby/SystemAccess.rb'
require 'BluePrintReader.rb'


class EngineBuilder
  @repoName=nil
  @hostname=nil
  @domain_name=nil
  @build_name=nil
  @web_protocol="HTTPS and HTTP"

  
  attr_reader :last_error,
              :repoName,
              :hostname,
              :domain_name,
              :build_name,
              :set_environments,
              :container_name,
              :environments,
              :runtime,
              :webPort,
              :http_protocol,
              :blueprint,
              :first_build
              
  class BuildError < StandardError
    attr_reader :parent_exception,:method_name
    def initialize(parent,method_name)
      @parent_exception = parent
    end

  end

  class DockerFileBuilder
    def initialize(reader,containername,hostname,domain_name,webport,builder)
      @hostname = hostname
      @container_name = containername
      @domain_name = domain_name
      @webPort = webport
      @blueprint_reader = reader
      @builder=builder

      @docker_file = File.open( @blueprint_reader.get_basedir + "/Dockerfile","a")

      @layer_count=0
    end

    def  log_build_output(line)
      @builder.log_build_output(line)
    end

    def log_build_errors(line)
      @builder.log_build_errors(line)
    end

    def count_layer
      ++@layer_count

      if @layer_count >75
        raise EngineBuilder.BuildError.new()
      end
    end

    def write_files_for_docker
      @docker_file.puts("")
      write_environment_variables
      write_stack_env
      write_services
      write_file_service
      
      #write_db_service
      #write_cron_jobs
      write_os_packages
      write_apache_modules
      write_user_local = true

      if write_user_local == true
        @docker_file.puts("RUN ln -s /usr/local/ /home/local;\\")
        @docker_file.puts("     chown -R $ContUser /usr/local/")
      end

      write_app_archives
      write_container_user
      chown_home_app
      write_worker_commands            
      write_sed_strings
      write_persistant_dirs
      write_persistant_files
      insert_framework_frag_in_dockerfile("builder.mid.tmpl")
      @docker_file.puts("")
      write_rake_list
      write_pear_list
      write_write_permissions_recursive #recursive firs (as can use to create blank dir)
      write_write_permissions_single

      @docker_file.puts("")
      @docker_file.puts("USER 0")
      count_layer()
      @docker_file.puts("run mkdir -p /home/fs/local/")
      count_layer()
      @docker_file.puts("")


      write_run_install_script

      write_data_permissions

      @docker_file.puts("USER 0")
      count_layer()

      @docker_file.puts("run mv /home/fs /home/fs_src")
      count_layer()
      @docker_file.puts("VOLUME /home/fs_src/")
      count_layer()
      @docker_file.puts("USER $ContUser")
      count_layer()
      insert_framework_frag_in_dockerfile("builder.end.tmpl")
      @docker_file.puts("")
      @docker_file.puts("VOLUME /home/fs/")
      count_layer()
   
      write_clear_env_variables
      

      @docker_file.close

    end

    def write_clear_env_variables
      @docker_file.puts("#Clear env")
      @blueprint_reader.environments.each  do |env|
        if env.build_time_only == true
          @docker_file.puts("ENV " + env.name + "\" \"")
          count_layer
        end
      end

    rescue Exception=>e
      log_exception(e)
      return false
    end

    def write_apache_modules
      if @blueprint_reader.apache_modules.count <1
        return
      end
      @docker_file.puts("#Apache Modules")
      ap_modules_str = String.new
      @blueprint_reader.apache_modules.each do |ap_module|

        ap_modules_str += ap_module + " "
      end
      @docker_file.puts("RUN a2enmod " + ap_modules_str)
      count_layer()
    end

    def write_environment_variables

      begin
        @docker_file.puts("#Environment Variables")
        #Fixme
        #kludge
        @docker_file.puts("#System Envs")
        @docker_file.puts("ENV TZ Sydney/Australia")
        count_layer
        
        @blueprint_reader.environments.each do |env|
          @docker_file.puts("#Blueprint ENVs")
          if env.value != nil
            env.value.sub!(/ /,"\\ ")
          end
           if  env.value !=nil && env.value.to_s.length >0 #env statement must have two arguments
            @docker_file.puts("ENV " + env.name + " " + env.value.to_s )
            count_layer
           end
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_persistant_dirs
      begin
        log_build_output("setup persistant Dirs")

        n=0
        @docker_file.puts("#Persistant Dirs")
        @blueprint_reader.persistant_dirs.each do |path|

          path.chomp!("/")
          @docker_file.puts("")
          @docker_file.puts("RUN  \\")
          dirname = File.dirname(path)
          @docker_file.puts("mkdir -p $CONTFSVolHome/$VOLDIR/" + dirname + ";\\")
          @docker_file.puts("if [ ! -d /home/" + path + " ];\\")
          @docker_file.puts("  then \\")
          @docker_file.puts("    mkdir -p /home/" + path +" ;\\")
          @docker_file.puts("  fi;\\")
          @docker_file.puts("mv /home/" + path + " $CONTFSVolHome/$VOLDIR/" + dirname + "/;\\")
          @docker_file.puts("ln -s $CONTFSVolHome/$VOLDIR/" + path + " /home/" + path)
          n=n+1
          count_layer
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def write_data_permissions
      @docker_file.puts("#Data Permissions")
      @docker_file.puts("USER 0")
      count_layer()
      @docker_file.puts("")
      @docker_file.puts("RUN /usr/sbin/usermod -u $data_uid data-user;\\")
      @docker_file.puts("chown -R $data_uid.$data_gid /home/app /home/fs ;\\")
      @docker_file.puts("chmod -R 770 /home/fs")
      count_layer
      @docker_file.puts("USER $ContUser")
      count_layer

    end

    def write_run_install_script
      @docker_file.puts("WorkDir /home/")
      @docker_file.puts("#Setup templates and run installer")
      @docker_file.puts("USER $ContUser")
      count_layer
      @docker_file.puts("RUN bash /home/setup.sh")
      count_layer
    end

    def write_persistant_files
      begin
        @docker_file.puts("#Persistant Files")
        log_build_output("set setup_env")
        src_paths = @blueprint_reader.persistant_files[:src_paths]
        dest_paths =  @blueprint_reader.persistant_files[:dest_paths]

        src_paths.each do |path|
          #          path = dest_paths[n]
          p :path
          p path

          dir = File.dirname(path)
          p :dir
          p dir
          if dir.present? == false || dir == nil || dir.length ==0 || dir =="."
            dir = "app/"
          end
          p :dir
          p dir
          @docker_file.puts("")
          @docker_file.puts("RUN mkdir -p /home/" + dir + ";\\")
          @docker_file.puts("  if [ ! -f /home/" + path + " ];\\")
          @docker_file.puts("    then \\")
          @docker_file.puts("      touch  /home/" + path +";\\")
          @docker_file.puts("    fi;\\")
          @docker_file.puts("  mkdir -p $CONTFSVolHome/$VOLDIR/" + dir +";\\")
          @docker_file.puts("\\")
          @docker_file.puts("   mv /home/" + path + " $CONTFSVolHome/$VOLDIR" + "/" + dir + ";\\")
          @docker_file.puts("    ln -s $CONTFSVolHome/$VOLDIR/" + path + " /home/" + path)
          count_layer

        end

      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    def  write_file_service
      begin
        @docker_file.puts("#File Service")
        @docker_file.puts("#FS Env")
#        @docker_file.puts("ENV CONTFSVolHome /home/fs/" )
#        count_layer
        @blueprint_reader.volumes.each_value do |vol|
          dest = File.basename(vol.remotepath)
#          @docker_file.puts("ENV VOLDIR /home/fs/" + dest)
#          count_layer
          @docker_file.puts("RUN mkdir -p $CONTFSVolHome/" + dest)
          count_layer
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end
    
    def write_services
      services = @blueprint_reader.services
      @docker_file.puts("#Service Environment Variables")
        services.each do |service_hash|
          p :service_hash
          p service_hash
          service_def =  @builder.get_service_def(service_hash)
            if service_def != nil
              p :processing
              p service_def
              
              service_environment_variables = service_def[:target_environment_variables]
                if service_environment_variables != nil
                  service_environment_variables.values.each do |env_variable_pair|
                    p :setting_values
                    p env_variable_pair
                    env_name = env_variable_pair[:environment_name]
                    value_name = env_variable_pair[:variable_name]
                    value=service_hash[:variables][value_name.to_sym] 
                    p :looking_for_
                    p value_name
                    p :as_symbol
                     p value_name.to_sym
                     p :in_service_hash
                     p service_hash
                     p :and_found
                     p value
                     
                    if value != nil && value.to_s.length >0
                      @docker_file.puts("ENV " + env_name + " " + value )
                      count_layer()
                    end
                  end
                    
                end
            end
        end
    end

    def write_sed_strings
      begin
        n=0
        @docker_file.puts("#Sed Strings")
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
        @docker_file.puts("#Rake Actions")
        @blueprint_reader.rake_actions.each do |rake_action|
          rake_cmd = rake_action[:action]
           if @builder.first_build == false &&  rake_action[:always_run] == false
             next
          end
          
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
        @docker_file.puts("#OS Packages")
        @blueprint_reader.os_packages.each do |package|
          if package != nil
            packages = packages + package + " "
          end
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
        log_build_output(frag_name)
        @docker_file.puts("#Framework Frag")
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
        @docker_file.puts("#Chown App Dir")
        log_build_output("Dockerfile:Chown")
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
        @docker_file.puts("#Worker Commands")
        log_build_output("Dockerfile:Worker Commands")
        scripts_path = @blueprint_reader.get_basedir + "/home/engines/scripts/"

        if Dir.exist?(scripts_path) == false
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
          File.chmod(0755,scripts_path + "pre-running.sh")
        end
      rescue Exception=>e
        log_exception(e)
        return false
      end
    end

    #    def write_cron_jobs
    #      begin
    #          if @blueprint_reader.cron_jobs.length >0
    #            @docker_file.puts("ENV CRONJOBS YES")
    #            count_layer
    ##            @docker_file.puts("RUN crontab  $data_uid /home/crontab ")
    ##            count_layer cron run from cron service
    #          end
    #        return true
    #      rescue Exception=>e
    #        log_exception(e)
    #        return false
    #      end
    #    end

#    def write_db_service
#      begin
#        @docker_file.puts("#Database Service")
#        log_build_output("Dockerfile:DB env")
#        @blueprint_reader.databases.each do |db|
#          @docker_file.puts("#Database Env")
#          @docker_file.puts("ENV dbname " + db.name)
#          count_layer
#          @docker_file.puts("ENV dbhost " + db.dbHost)
#          count_layer
#          @docker_file.puts("ENV dbuser " + db.dbUser)
#          count_layer
#          @docker_file.puts("ENV dbpasswd " + db.dbPass)
#          count_layer
#          flavor = db.flavor
#          if flavor == "mysql"
#            flavor = "mysql2"
#          elsif flavor == "pgsql"
#            flavor = "postgresql"
#          end
#          @docker_file.puts("ENV dbflavor " + flavor)
#          count_layer
#        end
#
#      rescue Exception=>e
#        log_exception(e)
#        return false
#      end
#    end

    def write_write_permissions_single
      begin
        @docker_file.puts("")
        @docker_file.puts("#Write Permissions Non Recursive")
        log_build_output("Dockerfile:Write Permissions Non Recursive")
        if @blueprint_reader.single_chmods == nil
          return
        end
        @blueprint_reader.single_chmods.each do |path|
          if path !=nil
            @docker_file.puts("RUN if [ ! -f /home/app/" + path + " ];\\" )
            @docker_file.puts("   then \\")
            @docker_file.puts("   mkdir -p  `dirname /home/app/" + path + "`;\\")
            @docker_file.puts("   touch  /home/app/" + path + ";\\")
            @docker_file.puts("     fi;\\")
            @docker_file.puts( "  chmod  775 /home/app/" + path )
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
        @docker_file.puts("#Write Permissions  Recursive")
        @docker_file.puts("")
        log_build_output("Dockerfile:Write Permissions Recursive")
        if @blueprint_reader.recursive_chmods == nil
          return
        end
        @blueprint_reader.recursive_chmods.each do |directory|
          if directory !=nil
            @docker_file.puts("RUN if [ -h  /home/app/"  + directory + " ] ;\\")
            @docker_file.puts("    then \\")
            @docker_file.puts("    dest=`ls -la /home/app/" + directory +" |cut -f2 -d\">\"`;\\")
            @docker_file.puts("    chmod -R gu+rw $dest;\\")
            @docker_file.puts("  elif [ ! -d /home/app/" + directory + " ] ;\\" )
            @docker_file.puts("    then \\")
            @docker_file.puts("       mkdir  \"/home/app/" + directory + "\";\\")
            @docker_file.puts("       chmod -R gu+rw \"/home/app/" + directory + "\";\\" )
            @docker_file.puts("  else\\")
            @docker_file.puts("   chmod -R gu+rw \"/home/app/" + directory + "\";\\")
            @docker_file.puts("     for dir in `find  /home/app/" + directory  + " -type d  `;\\")
            @docker_file.puts("       do\\")
            @docker_file.puts("           adir=`echo $dir | sed \"/ /s//_+_/\" |grep -v _+_` ;\\")
            @docker_file.puts("            if test -n $adir;\\")
            @docker_file.puts("                then\\")
            @docker_file.puts("                      dirs=\"$dirs $adir\";\\");
            @docker_file.puts("                fi;\\")
            @docker_file.puts("       done;\\")
            @docker_file.puts(" if test -n \"$dirs\" ;\\")
            @docker_file.puts("      then\\")
            @docker_file.puts("      chmod gu+x $dirs  ;\\")
            @docker_file.puts("fi;\\")
            @docker_file.puts("fi")

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
        @docker_file.puts("#App Archives")
        log_build_output("Dockerfile:App Archives")
        n=0
        #        srcs=String.new
        #        names=String.new
        #        locations=String.new
        #        extracts=String.new
        #        dirs=String.new
        @docker_file.puts("")

        @blueprint_reader.archives_details.each do |archive_details|
          arc_src = archive_details[:source_url]
          arc_name = archive_details[:package_name]
          arc_loc = archive_details[:destination]
          arc_extract = archive_details[:extraction_command]
          arc_dir = archive_details[:path_to_extracted]
          #          if(n >0)
          #            archive_details[:source_url]=arc_src
          #            archive_details[:package_name]=arc_name
          #            archive_details[:extraction_cmd]=arc_extract
          #            archive_details[:destination]=arc_loc
          #            archive_details[:path_to_extracted]=arc_dir
          #            srcs = srcs + " "
          #            names =names + " "
          #            locations = locations + " "
          #            extracts =extracts + " "
          #            dirs =dirs + " "
          #          end
          p "_+_+_+_+_+_+_+_+_+_+_"
          p archive_details
          p arc_src + "_" 
          p arc_name + "_" 
          p arc_loc + "_" 
          p arc_extract + "_" 
          p arc_dir +"|"
            
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
            @docker_file.puts("RUN git clone " + arc_src + " --depth 1 " )
            count_layer
            @docker_file.puts("USER 0  ")
            count_layer
            @docker_file.puts("RUN mv  " + arc_dir + " /home/app" +  arc_loc )
            count_layer
            @docker_file.puts("USER $ContUser")
            count_layer
          else
            @docker_file.puts("USER $ContUser")
            count_layer
            step_back=false

            if arc_dir == nil 
              step_back=true
              @docker_file.puts("RUN   mkdir /tmp/app")
              count_layer
              arc_dir = "app"
              @docker_file.puts("WORKDIR /tmp/app")
              count_layer
            else
              @docker_file.puts("WORKDIR /tmp")
              count_layer
            end

            @docker_file.puts("RUN   wget  -O \"" + arc_name + "\" \""  + arc_src + "\" ;\\" )
            if arc_extract!= nil
              @docker_file.puts(" " + arc_extract + " \"" + arc_name + "\" ;\\") # + "\"* 2>&1 > /dev/null ")
              @docker_file.puts(" rm \"" + arc_name + "\"")
            else
              @docker_file.puts("echo") #step past the next shell line implied by preceeding ;
            end
            @docker_file.puts("USER 0  ")
            count_layer
            if step_back==true
              @docker_file.puts("WORKDIR /tmp")
              count_layer
            end
            if  arc_loc.start_with?("/home/app") || arc_loc.start_with?("/home/local/")
              dest_prefix=""
            else
              dest_prefix="/home/app"
            end

            @docker_file.puts("run   if test ! -d " + arc_dir  +" ;\\")
            @docker_file.puts("       then\\")
            @docker_file.puts(" mkdir -p /home/app ;\\")
            @docker_file.puts(" fi;\\")
            @docker_file.puts(" mv " + arc_dir + " " + dest_prefix +  arc_loc )
            count_layer
            @docker_file.puts("USER $ContUser")
            count_layer

          end
        end

      rescue Exception=>e
        log_exception(e)
        return false
      end

    end

    def write_container_user
      begin
        @docker_file.puts("#Container Data User")
        log_build_output("Dockerfile:User")

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
        log_build_output("Dockerfile:Stack Environment")
        @docker_file.puts("#Stack Env")
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
      @docker_file.puts("#OPear List")
      log_build_output("Dockerfile:Pear List")
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
      log_build_errors( e.to_s)
      puts(e.to_s)
      @last_error=  e.to_s
      e.backtrace.each do |bt |
        p bt
      end
      return false
    end
    ##################### End of
  end

 
  #This class is to isolate the builder from the docker template output
  
  class BuilderPublic
    def initialize(builder)
     @builder = builder
    end
     def engine_name
       @builder.container_name
     end
     def domain_name
       @builder.domain_name
     end
     def hostname 
       @builder.hostname
     end
     def http_protocol
       @builder.http_protocol
     end
     def repoName
       @builder.repoName
     end
     def webPort
       @builder.webPort
     end
     def build_name
       @builder.build_name
     end
     def runtime
       @builder.runtime
     end     
     def set_environments 
       @builder.set_environments
     end     
     def environments
       @builder.environments
     end
     
     def mysql_host
       return "mysql.engines.internal"
     end
     
     def blueprint
       return @builder.blueprint
     end
     
     def random cnt
       len = cnt.to_i
       rnd = SecureRandom.hex(len)
#       p :RANDOM__________
#       p rnd.byteslice(0,len) 
       return rnd.byteslice(0,len) 
     end
     
     
    
  end

  def initialize(params,core_api)
    @container_name = params[:engine_name]
    @domain_name = params[:domain_name]
    @hostname = params[:host_name]
    custom_env= params[:software_environment_variables]
    #   custom_env=params
    @core_api = core_api
    @http_protocol = params[:http_protocol]
    p params
    @repoName= params[:repository_url]
    @cron_job_list = Array.new
    @build_name = File.basename(@repoName).sub(/\.git$/,"")
    @workerPorts=Array.new
    @webPort=8000
    @vols=Array.new
    @first_build = true
    #FIXme will be false but for now
    @overwrite_existing_services = true 
    
    @builder_public = BuilderPublic.new(self)
    @system_access = SystemAccess.new()
    p :custom_env
    p custom_env

    if custom_env == nil
      @set_environments = Hash.new
      @environments = Array.new
    elsif  custom_env.instance_of?(Array) == true
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      #FIXME need to vet all environment variables
      @set_environments = Hash.new
    else
      env_array = custom_env.values
      custom_env_hash = Hash.new

      env_array.each do |env_hash|
        p :env_hash
        p env_hash

        if env_hash != nil && env_hash[:name] !=nil && env_hash[:value] != nil
          env_hash[:name] = env_hash[:name].sub(/_/,"")
          custom_env_hash.store(env_hash[:name],env_hash[:value])
        end
      end
      p :Merged_custom_env
      p custom_env_hash
      @set_environments =  custom_env_hash
      @environments = Array.new
    end
    @runtime=String.new
    @databases= Array.new

    begin
      FileUtils.mkdir_p(get_basedir)
      @log_file=  File.new(SysConfig.DeploymentDir + "/build.out", File::CREAT|File::TRUNC|File::RDWR, 0644)
      @err_file=  File.new(SysConfig.DeploymentDir + "/build.err", File::CREAT|File::TRUNC|File::RDWR, 0644)
      @log_pipe_rd, @log_pipe_wr = IO.pipe
      @error_pipe_rd, @error_pipe_wr = IO.pipe
    rescue
      log_exception(e)
    end
  end

  def close_all
    if @log_file.closed? == false
      @log_file.close()
    end
    if@err_file.closed? == false
      @err_file.close()
    end

    if @log_pipe_wr.closed? == false
      @log_pipe_wr.close()
    end

    if @error_pipe_wr.closed? == false
      @error_pipe_wr.close()
    end
  end

  def get_build_log_stream
    return @log_pipe_rd
  end

  def get_build_err_stream
    @error_pipe_rd
  end

  def  log_build_output(line)
    @log_file.puts(line)
    @log_file.flush
    # @log_pipe_wr.puts(line)
  rescue
    return

  end

  def log_build_errors(line)
    @err_file.puts(line)
    @err_file.flush
    #    @error_pipe_wr.puts(line)
  end

  def setup_framework_logging
    begin
      rmt_log_dir_var_fname=get_basedir + "/home/LOG_DIR"
      if File.exist?(rmt_log_dir_var_fname)
        rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
        rmt_log_dir = rmt_log_dir_varfile.read
      else
        rmt_log_dir="/var/log"
      end
      local_log_dir = SysConfig.SystemLogRoot + "/containers/" + @hostname
      if Dir.exist?(local_log_dir) == false
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

      if Dir.exist?(dir)
        backup=dir + ".backup"
        if Dir.exist?(backup)
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
      log_build_output("Reading Blueprint")
      blueprint_file_name= get_basedir + "/blueprint.json"
      blueprint_file = File.open(blueprint_file_name,"r")
      blueprint_json_str = blueprint_file.read
      blueprint_file.close

      # @blueprint = JSON.parse(blueprint_json_str)
      json_hash = JSON.parse(blueprint_json_str)
      p :symbolized_hash
#      test_hash = json_hash
#      test_hash.keys.each do |key|
#        test_hash[(key.to_sym rescue key) || key] = myhash.delete(key)
#      end
#      p test_hash
  hash =  SystemUtils.symbolize_keys(json_hash)
      return hash
      
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def clone_repo
    begin
      log_build_output("Clone Blueprint Repository")
      g = Git.clone(@repoName, @build_name, :path => SysConfig.DeploymentDir)
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end



#  def create_cron_service
#    begin
#
#      log_build_output("Cron file")
#
#      if @blueprint_reader.cron_jobs != nil && @blueprint_reader.cron_jobs.length >0
#
#        @blueprint_reader.cron_jobs.each do |cj|
#          cj_hash = Hash.new
#          cj_hash[:name] =@container_name
#          cj_hash[:container_name] = @container_name
#          cj_hash[:cron_job]=cj
#          cj_hash[:parent_engine] = @containerName
#          #               cron_file.puts(cj)
#          #               p :write_cron_job
#          #               p cj
#          @cron_job_list.push(cj_hash)
#          p @cron_job_list
#        end
#        #             cron_file.close
#      end
#
#      return true
#
#    rescue Exception=>e
#      log_exception(e)
#      return false
#    end
#  end

  def setup_default_files
    log_build_output("Setup Default Files")
    if setup_global_defaults == false
      return false
    else
      return setup_framework_defaults
    end
  end
#
#  def create_db_service(name,flavor)
#    begin
#      log_build_output("Create DB Service")
#      db = DatabaseService.new(@hostname,name,SysConfig.DBHost,name,name,flavor)
#      databases.push(db)
#      create_database_service db
#    rescue Exception=>e
#      log_exception(e)
#      return false
#    end
#  end

  def build_init
    begin
      log_build_output("Building Image")
      # cmd="cd " + get_basedir + "; docker build  -t " + @hostname + "/init ."
      cmd="/usr/bin/docker build  -t " + @container_name + "/deploy " +  get_basedir
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
      log_build_output("Lauching Engine")
      retval =  managed_container.create_container
      if retval == false
        puts "Failed to Start Container " +  managed_container.last_error
        log_build_errors("Failed to Launch")
      end

      return retval
    rescue Exception=>e

      log_exception(e)
      return false
    end
  end

  def setup_global_defaults
    begin
      log_build_output("Setup globel defaults")
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/global/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def setup_framework_defaults
    log_build_output("Copy in default templates")
    begin
      cmd=  "cp -r " +  SysConfig.DeploymentTemplates + "/" +  @blueprint_reader.framework + "/* "  + get_basedir
      system  cmd
    rescue Exception=>e
      log_exception(e)
      return false
    end
  end

  def get_blueprint_from_repo
    log_build_output("Backup last build")
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
    log_build_output("Setting Web port")
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
      log_build_output("Read Web User")
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

      log_build_output("Reading Blueprint")
      @blueprint = load_blueprint
      if @blueprint ==  nil ||  @blueprint == false
        return false
      end

      @blueprint_reader = BluePrintReader.new(@build_name,@container_name,@blueprint,self)
      @blueprint_reader.process_blueprint

      if  setup_default_files == false
        return false
      end
      
      
      
      compile_base_docker_files

      if @blueprint_reader.web_port != nil
        @webPort = @blueprint_reader.web_port
      else
        read_web_port
      end
      
      read_web_user
      
      create_persistant_services #need to de-register these if build fails But not deregister those that existed prior
      
      create_template_files
      create_php_ini
      create_apache_config                 
      create_scritps
        @blueprint_reader.environments.each do |env|
          p :env_before
          p env.value
              env.value = process_templated_string(env.value)
              p :env_after
              p env.value
          end
                 index=0
                 #FIXME There has to be a ruby way
                 @blueprint_reader.sed_strings[:sed_str].each do |sed_string|                   
                   sed_string = process_templated_string(sed_string)
                   @blueprint_reader.sed_strings[:sed_str][index] = sed_string
                   index+=1
                  end       
                 
      dockerfile_builder = DockerFileBuilder.new( @blueprint_reader,@container_name, @hostname,@domain_name,@webPort,self)
      dockerfile_builder.write_files_for_docker
      
      env_file = File.new(get_basedir + "/home/app.env","a")
      env_file.puts("")
      @blueprint_reader.environments.each do |env|
        env_file.puts(env.name)
      end
      @set_environments.each do |env|
        env_file.puts(env[0])
      end
      env_file.close

      setup_framework_logging

#      log_build_output("Creating db Services")
#      @blueprint_reader.databases.each() do |db|
#        create_database_service db
#      end
      
     
      if  build_init == false
        log_build_errors("Error Build Image failed")
        @last_error =  " " + tail_of_build_log
        post_failed_build_clean_up
        return false
      else

        if @core_api.image_exists?(@container_name) == false
          @last_error = " " + tail_of_build_log
          post_failed_build_clean_up
          return false
          #return EnginesOSapiResult.failed(@container_name,"Build Image failed","build Image")
        end

        #needs to be moved to services dependant on the new BPDS
        #create_cron_service

#        log_build_output("Creating vol Services")
#        @blueprint_reader.databases.each() do |db|
#          create_database_service db
#        end
#
#        primary_vol=nil
#        @blueprint_reader.volumes.each_value() do |vol|
#          create_file_service vol
#          if primary_vol == nil
#            primary_vol =vol
#          end
#        end
        log_build_output("Creating Deploy Image")
        mc = create_managed_container()
        if mc != nil
          create_non_persistant_services   
        end
      end

      close_all

      return mc

    rescue Exception=>e

      log_exception(e)
    post_failed_build_clean_up
      close_all
      return false
    end
  end

  def post_failed_build_clean_up
    #remove containers
    #remove persistant services (if created/new)
    #deregister non persistant services (if created)
    p :Clean_up_Failed_build
    @blueprint_reader.services.each do |service_hash|
      if service_hash[:fresh] == true 
        service_hash[:delete_persistant]=true
        @core_api.dettach_service(service_hash) #true is delete persistant
      end
    end
  end
  
  def create_template_files
    if  @blueprint[:software].has_key?(:template_files) && @blueprint[:software][:template_files] != nil
      @blueprint[:software][:template_files].each do |template_hash|
        write_software_file( "/home/engines/templates/" + template_hash[:path],template_hash[:content])
    end
  end
  end
  
  def create_httaccess
    if @blueprint[:software].has_key?(:apache_htaccess_files) && @blueprint[:software][:apache_htaccess_files]  != nil
      @blueprint[:software][:apache_htaccess_files].each do |htaccess_hash|
        write_software_file("/home/engines/htaccess_files" + template_hash[:directory]+"/.htaccess",template_hash[:htaccess_content])
      end
    end
  end
  
  def   create_scritps
    
      FileUtils.mkdir_p(get_basedir() + SysConfig.ScriptsDir)      
      create_start_script
      create_install_script
      create_post_install_script
  end
  
   def create_start_script
     if @blueprint[:software].has_key?(:custom_start_script) &&  @blueprint[:software][:custom_start_script] != nil
       start_script_file = File.open(get_basedir() + SysConfig.StartScript,"w", :crlf_newline => false)
       start_script_file.puts(@blueprint[:software][:custom_start_script])
       start_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.StartScript)
     end
   end
   
   def create_install_script
     if @blueprint[:software].has_key?(:custom_install_script) &&  @blueprint[:software][:custom_install_script] != nil
       install_script_file = File.open(get_basedir() + SysConfig.InstallScript,"w", :crlf_newline => false)
       install_script_file.puts(@blueprint[:software][:custom_install_script])
       install_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.InstallScript)
       end     
   end
   def create_post_install_script
     if @blueprint[:software].has_key?(:custom_post_install_script) && @blueprint[:software][:custom_post_install_script] != nil
       post_install_script_file = File.open(get_basedir() + SysConfig.PostInstallScript,"w", :crlf_newline => false)
       post_install_script_file.puts(@blueprint[:software][:custom_post_install_script])
       post_install_script_file.close
       File.chmod(0755,get_basedir() + SysConfig.PostInstallScript)
       end    
   end
  def create_php_ini
    FileUtils.mkdir_p(get_basedir() + File.dirname(SysConfig.CustomPHPiniFile))
    if @blueprint[:software].has_key?(:custom_php_inis) && @blueprint[:software][:custom_php_inis]  != nil
      
      php_ini_file = File.open(get_basedir() + SysConfig.CustomPHPiniFile,"w", :crlf_newline => false)              
      @blueprint[:software][:custom_php_inis].each do |php_ini_hash|
        php_ini_file.puts(php_ini_hash[:content])
      end
      php_ini_file.close
       
    end
  end
    
    def create_apache_config
      FileUtils.mkdir_p(get_basedir() + File.dirname(SysConfig.CustomApacheConfFile))
      if @blueprint[:software].has_key?(:custom_apache_conf) && @blueprint[:software][:custom_apache_conf]  != nil            
        write_software_file(SysConfig.CustomApacheConfFile,@blueprint[:software][:custom_apache_conf])               
         
      end  
  end
 
  def write_software_file(container_filename_path,content)
    dir = File.dirname(get_basedir() + container_filename_path)
    p :dir_for_write_software_file
    p dir
    
    if Dir.exist?(dir) == false
      FileUtils.mkdir_p(dir)
    end
   out_file  = File.open(get_basedir() + container_filename_path ,"w", :crlf_newline => false)
   content = process_templated_string(content)
   out_file.puts(content)
 end
 
  def  compile_base_docker_files
    
    file_list = Dir.glob(@blueprint_reader.get_basedir + "/Dockerfile*.tmpl")
      file_list.each do |file|
        process_dockerfile_tmpl(file)
      end 
              
  end
  
  def process_templated_string(template)
       template = apply_system_variables(template)
       template = apply_build_variables(template)
       template = apply_blueprint_variables(template)
       template = apply_engines_variables(template)
    return template
  end
  
  def process_dockerfile_tmpl(filename)
    p :dockerfile_template_processing
    p filename
    template = File.read(filename)
    
    template = process_templated_string(template)
    output_filename = filename.sub(/.tmpl/,"")
    
    out_file = File.new(output_filename,"w")
    out_file.write(template)
    out_file.close()            
  end

  
  def apply_system_variables(template)
    template.gsub!(/_System\([a-z].*\)/) { | match |
      resolve_system_variable(match)
    } 
    return template
  end
  
  def apply_build_variables(template)
    template.gsub!(/_Builder\([a-z].*\)/) { | match |
          resolve_build_variable(match)
        } 
        return template
  end
  
  def resolve_system_variable(match)
    name = match.sub!(/_System\(/,"")
    name.sub!(/[\)]/,"")
    p :getting_system_value_for
    p name
    
    var_method = @system_access.method(name.to_sym)
    val = var_method.call
    
    p :got_val
    p val
    
    return val
    
  rescue Exception=>e
    SystemUtils.log_exception(e) 
    
    return ""
  end
#_Blueprint(software,license_name)
#_Blueprint(software,rake_tasks,name)

def apply_blueprint_variables(template)
  template.gsub!(/_Blueprint\([a-z,].*\)/) { | match |
    resolve_blueprint_variable(match)
      } 
      return template
end

def resolve_blueprint_variable(match)
  name = match.sub!(/_Blueprint\(/,"")
  name.sub!(/[\)]/,"")
  p :getting_system_value_for
  p name
  val =""
  
   keys = name.split(',')
   hash = @builder_public.blueprint
   keys.each do |key|
     if key == nil || key.length < 1
       break
     end
     p :key
     p key
     val = hash[key.to_sym]
     p :val
     p val     
     if val != nil
       hash=val
     end
   end     
  
  p :got_val
  p val
  
  return val
  
rescue Exception=>e
    SystemUtils.log_exception(e) 
  return ""
end

  def resolve_build_variable(match)
    name = match.sub!(/_Builder\(/,"")
    name.sub!(/[\)]/,"")
    p :getting_system_value_for
    p name.to_sym
    if name.include?('(')  == true
      cmd = name.split('(')
      name = cmd[0]
      if cmd.count >1
        args = cmd[1]     
        args.sub!(/\)/,"")
        args_array = args.split
      end
    end
      
    var_method = @builder_public.method(name.to_sym)
    if args
      p :got_args
      val = var_method.call args
    else
      val = var_method.call 
    end
    p :got_val
    p val
    return val
    rescue Exception=>e
        SystemUtils.log_exception(e) 
       return ""
  end
  
  def resolve_engines_variable
    name = match.sub!(/_Engines\(/,"")
    name.sub!(/[\)]/,"")
    p :getting_system_value_for
    p name.to_sym
    
    return @blueprint_reader.environments[name.to_sym]
    
    rescue Exception=>e
      p @blueprint_reader.environments
         SystemUtils.log_exception(e) 
        return ""
  end
  
  def apply_engines_variables(template)

    template.gsub!(/_Engines\([a-z].*\)/) { | match |
          resolve_engines_variable(match)
        } 
        return template
  end

  
  def create_non_persistant_services
    @blueprint_reader.services.each() do |service_hash|
       #FIX ME Should call this but Keys dont match blueprint designer issue
       #@core_api.add_service(service,mc)     
      service_hash[:parent_engine]=@container_name
        
       service_def =  get_service_def(service_hash)
      if service_def == nil
        p :failed_to_load_service_definition
        p service_hash[:type_path]
        p service_hash[:publisher_namespace]
        return false
      end
        if service_def[:persistant] == true
          next                 
        end
      service_hash[:service_handle] = service_hash[:variables][:name]
         p :adding_service
         p service_hash   
      @core_api.attach_service(service_hash)
       end
  end
  
  
  def get_service_def(service_hash)
    p service_hash[:type_path]
      p service_hash[:publisher_namespace]
    return     SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace] )
  end
  
  def create_persistant_services
    @blueprint_reader.services.each() do |service_hash|
      
      service_hash[:parent_engine]=@container_name
#      p :service_def_for
#      p service_hash[:type_path]
#      p service_hash[:publisher_namespace]
   
      service_def = get_service_def(service_hash)
#      p  service_def
       
       if service_def == nil
         p :failed_to_load_service_definition
         p :servicetype_name
         p service_hash[:service_type]
         p :service_provider
         p service_hash[:publisher_namespace]
         return false
       end
      if service_def[:persistant] == false
        next                 
      end
      p :adding_service
     
      puts "+=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++"
      p service_hash   
      puts "+=++=++=++=++=++=++=++=++=++=++=++=++=++=++=++"
      p :target_envs
      p service_def[:target_environment_variables]
     
      if service_hash[:servicetype_name] == "filesystem"
         add_file_service(service[:name], service[:engine_path])
      end

      service_hash[:service_handle] = service_hash[:variables][:name]
        p :LOOKING_FOR_
        p service_hash
     if  @core_api.find_service_consumers(service_hash) == false              
       @first_build = true
       service_hash[:fresh]=true
     else       
       service_hash[:fresh]=false
       @first_build = false
     end
      p :attach_service
       p service_hash
      @core_api.attach_service(service_hash)
            
    end
  end
  
  def fill_in_dynamic_vars(service_hash)
    p "FILLING_+@+#+@+@+@+@+@+"
    if service_hash.has_key?(:variables) == false || service_hash[:variables] == nil
      return
    end
    service_hash[:variables].each do |variable|
      p variable
      if variable[1] != nil && variable[1].start_with?("_")
      #variable[1].sub!(/\$/,"")
        result = evaluate_function(variable[1])
        service_hash[:variables][variable[0]] = result
    end
  end
end
def evaluate_function(function)
     if function.start_with?("_System")
       return resolve_system_variable(function)
     elsif function.start_with?("_Builder")
       return resolve_build_variable(function)
     elsif function.start_with?("_Blueprint")
       return resolve_blueprint_variable(function)
     end
     #if no match return orginial
     return function
rescue Exception=> e
  return ""
  
end
  def tail_of_build_log
    retval = String.new
    lines = File.readlines(SysConfig.DeploymentDir + "/build.out")
    lines_count = lines.count -1
    start = lines_count - 10
    for n in start..lines_count
      retval+=lines[n]
    end
    return retval
  end

  def rebuild_managed_container  engine
    @engine  = engine
    log_build_output("Starting Rebuild")
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
      log_build_output("Setting up rebuild")
      FileUtils.mkdir_p(get_basedir)
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
    log_build_output("Creating ManagedEngine")
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

    p :set_cron_job_list
    p @cron_job_list
    mc.set_cron_job_list(@cron_job_list)
    #:http_protocol=>"HTTPS and HTTP"
    mc.set_protocol(@protocol)
    mc.conf_register_site=( true) # needs some intelligence here for worker only
    mc.conf_self_start= (true)
    mc.save_state # no config.yaml throws a no such container so save so others can use
    if mc.save_blueprint(@blueprint) == false
      log_build_errors( "Failed to save blueprint " + @blueprint.to_s)
    end

    bp = mc.load_blueprint
    p  bp
    log_build_output("Launching")
    #this will fail as no api at this stage
    if mc.core_api != nil
      if launch_deploy(mc) == false
        log_build_errors("Failed to Launch")
      end
      log_build_output("Applying Volume settings and Log Permissions")
      #FIXME need to check results from following
      @core_api.run_volume_builder(mc ,@webUser)
      #  mc.start_container
    end
    return mc
  end

  protected

  def log_exception(e)
    log_build_errors( e.to_s)
    puts(e.to_s)

    @last_error=  e.to_s
    n=0
    e.backtrace.each do |bt |
      p bt
      if n>10
        break
      end
      ++n
    end
    #close_all
  end

  def debug(fld)
    puts "ERROR: "
    p fld
  end

  require 'open3'

  def run_system(cmd)
    log_build_output("Running " + cmd)
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
            log_build_output(line)
            if stderr_is_open
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              log_build_errors(err)
            end
          }
        rescue Errno::EIO
          res += line.chop
          log_build_output(oline)
          if stderr_is_open
            err  = stderr.read_nonblock(1000)
            error_mesg += err
            log_build_errors(err)
            p :EIO_retry
            retry
          end
        rescue  IO::WaitReadable
          # p :wait_readable_retrt
          retry
        rescue EOFError
          if stdout.closed? == false
            stderr_is_open = false
            p :EOF_retry
            retry
          else if  stderr.closed? == true
              return
            else
              err  = stderr.read_nonblock(1000)
              error_mesg += err
              log_build_errors(err)
              return
            end
          end
        end

        if error_mesg.include?("Error:") || error_mesg.include?("FATA")
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

