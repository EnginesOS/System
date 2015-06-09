
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
   # write_services
    write_file_service
    
    #write_db_service
    #write_cron_jobs
    write_os_packages
   
    write_user_local = true

    if write_user_local == true
      @docker_file.puts("RUN ln -s /usr/local/ /home/local;\\")
      @docker_file.puts("     chown -R $ContUser /usr/local/")
    end
    
    set_user("$ContUser")
   
    
    write_app_archives
    set_user("$ContUser")
    
    
    write_container_user
    
    set_user("0")
         
    chown_home_app
   
    set_user("$ContUser")
 
    write_worker_commands            
    write_sed_strings
    write_persistant_dirs
    write_persistant_files
    insert_framework_frag_in_dockerfile("builder.mid.tmpl")
    @docker_file.puts("")
    write_rake_list
    
    @docker_file.puts("")
    set_user("0")
    
    write_pear_modules 
    write_php_modules 
    write_pecl_modules 
    write_apache_modules    

    write_write_permissions_recursive #recursive firs (as can use to create blank dir)
    write_write_permissions_single

    @docker_file.puts("")

    @docker_file.puts("run mkdir -p /home/fs/local/")
    count_layer()
    @docker_file.puts("")

    set_user("$ContUser")
    write_run_install_script
    set_user("0")
    write_data_permissions

    

    @docker_file.puts("run mv /home/fs /home/fs_src")
    count_layer()
    @docker_file.puts("VOLUME /home/fs_src/")
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
        @docker_file.puts("ENV " + env.name + " .")
        count_layer
      end
    end

  rescue Exception=>e
    SystemUtils.log_exception(e)
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
  def write_php_modules
    if @blueprint_reader.php_modules.count <1
      return
    end
    @docker_file.puts("#PHP Modules")
    php_modules_str = String.new
    @blueprint_reader.php_modules.each do |php_module|

      php_modules_str += php_module + " "
    end
    @docker_file.puts("RUN php5enmod  " + php_modules_str)
    count_layer()
  end

  def write_environment_variables

    begin
      @docker_file.puts("#Environment Variables")
      #Fixme
      #kludge
#      @docker_file.puts("#System Envs")
#      @docker_file.puts("ENV TZ Sydney/Australia")
#      count_layer
      
      @blueprint_reader.environments.each do |env|
        @docker_file.puts("#Blueprint ENVs")
        if env.value && env.value != nil && env.value.to_s.length >0
          p :env_val
          p env.value
          env.value = env.value.sub(/ /,"\\ ")
        end
         if  env.value !=nil && env.value.to_s.length >0 #env statement must have two arguments
          @docker_file.puts("ENV " + env.name + " " + env.value.to_s )
          count_layer
         end
      end

    rescue Exception=>e
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
      return false
    end
  end

  def write_data_permissions
    @docker_file.puts("#Data Permissions")

    @docker_file.puts("")
    @docker_file.puts("RUN /usr/sbin/usermod -u $data_uid data-user;\\")
    @docker_file.puts("chown -R $data_uid.$data_gid /home/app /home/fs ;\\")
    @docker_file.puts("chmod -R 770 /home/fs")
    count_layer
   

  end

  def write_run_install_script
    @docker_file.puts("WorkDir /home/")
    @docker_file.puts("#Setup templates and run installer")

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
        if  dir == nil || dir.length ==0 || dir =="."
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
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
      return false
    end
  end
  

#  def write_services
#    services = @blueprint_reader.services
#    @docker_file.puts("#Service Environment Variables")
#      services.each do |service_hash|
#        p :service_hash
#        p service_hash
#        service_def =  @builder.get_service_def(service_hash)
#          if service_def != nil
#            p :processing
#            p service_def
#            
#            service_environment_variables = service_def[:target_environment_variables]
#              if service_environment_variables != nil
#                service_environment_variables.values.each do |env_variable_pair|
#                  p :setting_values
#                  p env_variable_pair
#                  env_name = env_variable_pair[:environment_name]
#                  value_name = env_variable_pair[:variable_name]
#                  value=service_hash[:variables][value_name.to_sym] 
#                  p :looking_for_
#                  p value_name
#                  p :as_symbol
#                   p value_name.to_sym
#                   p :in_service_hash
#                   p service_hash
#                   p :and_found
#                   p value
#                   
#                  if value != nil && value.to_s.length >0
#                    @docker_file.puts("ENV " + env_name + " " + value )
#                    count_layer()
#                  end
#                end
#                  
#              end
#          end
#      end
#  end

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
SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
      return false
    end
  end

  def chown_home_app
    begin
      @docker_file.puts("#Chown App Dir")
      log_build_output("Dockerfile:Chown")
      
      @docker_file.puts("RUN if [ ! -d /home/app ];\\")
      @docker_file.puts("  then \\")
      @docker_file.puts("    mkdir -p /home/app ;\\")
      @docker_file.puts("  fi;\\")
      @docker_file.puts(" mkdir -p /home/fs ; mkdir -p /home/fs/local ;\\")
      @docker_file.puts(" chown -R $ContUser /home/app /home/fs /home/fs/local")
      count_layer

    rescue Exception=>e
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
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
          @docker_file.puts( "  chown $ContUser /home/app/" + path + ";\\")
          @docker_file.puts( "   chmod  775 /home/app/" + path )
          count_layer
        end
      end

    rescue Exception=>e
      SystemUtils.log_exception(e)
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
          @docker_file.puts("       mkdir  -p \"/home/app/" + directory + "\";\\")
          @docker_file.puts( "      chown $data_uid  \"/home/app/" +directory + "\";\\")
          @docker_file.puts("       chmod -R gu+rw \"/home/app/" + directory + "\";\\")         
          @docker_file.puts("  else\\")

          @docker_file.puts("   chmod -R gu+rw \"/home/app/" + directory + "\";\\")
          @docker_file.puts("     for dir in `find  /home/app/" + directory  + " -type d  `;\\")
          @docker_file.puts("       do\\")
          @docker_file.puts("           adir=`echo $dir | sed \"/ /s//_+_/\" |grep -v _+_` ;\\")
          @docker_file.puts("            if test -n $adir;\\")
          @docker_file.puts("                then\\")
          @docker_file.puts("                      dirs=`echo $dirs \"$adir\"`;\\");
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
    SystemUtils.log_exception(e)
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
          
        if arc_loc == "./" || arc_loc == "." 
          arc_loc=""
        elsif arc_loc.end_with?("/")
          arc_loc = arc_loc.chop() #note not String#chop
        end
        
        if arc_extract == "git"
          @docker_file.puts("WORKDIR /tmp")
          count_layer
          @docker_file.puts("RUN git clone " + arc_src + " --depth 1 " )
          count_layer
          set_user("0")
          @docker_file.puts("RUN mv  " + arc_dir + " /home/app/" +  arc_loc )
          count_layer
          set_user("$ContUser")
        else
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
          set_user("0")
          if step_back==true
            @docker_file.puts("WORKDIR /tmp")
            count_layer
          end
          if  arc_loc.start_with?("/home/app") == false && arc_loc.start_with?("/home/local/") == false
            dest_prefix="/home/app"
          else
            dest_prefix=""
          end

          @docker_file.puts("run   if test ! -d " + arc_dir  +" ;\\")
          @docker_file.puts("       then\\")
          @docker_file.puts(" mkdir -p " + dest_prefix + "/" + arc_loc  + " ;\\")
          @docker_file.puts(" fi;\\")
           if dest_prefix != "" &&  dest_prefix != "/home/app"
              @docker_file.puts(" mkdir -p " + dest_prefix + " ;\\")
           end
          @docker_file.puts(" mv " + arc_dir + " " + dest_prefix +  arc_loc )
          count_layer
          first_archive = false
        end
      end

    rescue Exception=>e
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
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
      SystemUtils.log_exception(e)
      return false
    end
  end

  def write_pear_modules 
    @docker_file.puts("#OPear modules ")
    log_build_output("Dockerfile:Pear modules ")
    if @blueprint_reader.pear_modules.count >0
      @docker_file.puts("RUN   wget http://pear.php.net/go-pear.phar;\\")
      @docker_file.puts("  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\")
      @docker_file.puts("  php go-pear.phar")
      count_layer

      @blueprint_reader.pear_modules.each do |pear_mod|
        if pear_mod !=nil
          #for pear
          #@docker_file.puts("RUN  pear install pear_mod " + pear_mod )
          # for pecl
          @docker_file.puts("RUN  pear install  " + pear_mod )
          count_layer
        end
      end
    end
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return false
  end
def write_pecl_modules 
  @docker_file.puts("#Pecl modules ")
  log_build_output("Dockerfile:Pecl modules ")
  if @blueprint_reader.pecl_modules.count >0
    @docker_file.puts("RUN   wget http://pear.php.net/go-pear.phar;\\")
    @docker_file.puts("  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\")
    @docker_file.puts("  php go-pear.phar")
    count_layer

    @blueprint_reader.pecl_modules.each do |pecl_mod|
      if pear_mod !=nil
        #for pear
        #@docker_file.puts("RUN  pear install pear_mod " + pear_mod )
        # for pecl
        @docker_file.puts("RUN  pecl install  " + pecl_mod )
        count_layer
      end
    end
  end
rescue Exception=>e
  SystemUtils.log_exception(e)
  return false
end
  def set_user(user)
    @docker_file.puts("User " + user)
    count_layer
  end
  protected

  ##################### End of
end

