class DockerFileBuilder
  def initialize(reader, _containername, hostname, domain_name, webport, builder)
    @hostname = hostname
    # @container_name = containername
    @domain_name = domain_name
    @web_port = webport
    @blueprint_reader = reader
    @builder = builder
    @docker_file = File.open(@builder.basedir + '/Dockerfile', 'a')
    @layer_count = 0
  end

  def log_build_output(line)
    @builder.log_build_output(line)
  end

  def log_build_errors(line)
    @builder.log_build_errors(line)
  end

  def count_layer
    @layer_count += 1
    if @layer_count > 75
       EngineBuilder.BuildError.new
    end
  end

  def write_files_for_docker
    write_line('')
    write_environment_variables
    write_stack_env
    write_file_service
    write_os_packages
    write_user_local = true
    setup_user_local if write_user_local 
    set_user('$ContUser')
    write_app_archives
    set_user('$ContUser')
    write_container_user
    set_user('0')
    chown_home_app
    set_user('$ContUser')
    write_database_seed
    write_worker_commands
    write_sed_strings
    write_persistant_dirs
    write_persistant_files
    insert_framework_frag_in_dockerfile('builder.mid.tmpl')
    write_line('')
    write_rake_list
    write_line('')
    set_user('0')
    write_modules
    write_permissions
    write_line('')
    write_line('run mkdir -p /home/fs/local/')    
    write_line('')
    set_user('0')
    write_data_permissions
    set_user('$ContUser')
    write_run_install_script
    setup_persitant_app if @builder.app_is_persistant
    prepare_persitant_source 
    finalise_docker_file
    return true
  end
  
  def setup_user_local  
    write_line('RUN ln -s /usr/local/ /home/local;\\')
    write_line('     chown -R $ContUser /usr/local/')
  end
  
  def finalise_docker_file
    insert_framework_frag_in_dockerfile('builder.end.tmpl')
    write_line('')
    write_line('VOLUME /home/fs/')    
    write_clear_env_variables
    @docker_file.close
  end
  
  def prepare_persitant_source
    write_line('run mv /home/fs /home/fs_src')    
    write_line('VOLUME /home/fs_src/')   
  end
  
  def setup_persitant_app
    write_line('RUN cp -rp /home/app /home/app_src')      
    write_line('VOLUME /home/app_src/')     
end

  def write_permissions
    write_write_permissions_recursive # recursive firs (as can use to create blank dir)
    write_write_permissions_single
  end

  def write_modules
    write_pear_modules
     write_php_modules
     write_pecl_modules
     write_apache_modules
  end
  def write_clear_env_variables
    write_line('#Clear env')
    @blueprint_reader.environments.each do |env|
      write_line('ENV ' + env.name + ' .') if env.build_time_only
    end

  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_apache_modules
    return false if @blueprint_reader.apache_modules.count < 1
    write_line('#Apache Modules')
    ap_modules_str = ''
    @blueprint_reader.apache_modules.each do |ap_module|
      ap_modules_str += ap_module + ' '
    end
    write_line('RUN a2enmod ' + ap_modules_str)    
  end

  def write_php_modules
    if @blueprint_reader.php_modules.count < 1
      return
    end
    write_line('#PHP Modules')
    php_modules_str = ''
    @blueprint_reader.php_modules.each do |php_module|
      php_modules_str += php_module + ' '
    end
    write_line('RUN php5enmod  ' + php_modules_str)   
  end

  def write_environment_variables
    write_line('#Environment Variables')    
    @blueprint_reader.environments.each do |env|
      write_line('#Blueprint ENVs')
      if env.value && env.value.nil? == false && env.value.to_s.length > 0
        p :env_val
        p env.value
        env.value = env.value.sub(/ /, '\\ ')
      end
      if env.value.nil? == false && env.value.to_s.length > 0 # env statement must have two arguments
        write_line('ENV ' + env.name + ' ' + env.value.to_s)      
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_persistant_dirs
    log_build_output('setup persistant Dirs')
    n = 0
    write_line('#Persistant Dirs')
    @blueprint_reader.persistant_dirs.each do |path|
      path.chomp!('/')
      write_line('')
      write_line('RUN  \\')
      dirname = File.dirname(path)
      write_line('mkdir -p $CONTFSVolHome/$VOLDIR/' + dirname + ';\\')
      write_line('if [ ! -d /home/' + path + ' ];\\')
      write_line('  then \\')
      write_line('    mkdir -p /home/' + path + ' ;\\')
      write_line('  fi;\\')
      write_line('mv /home/' + path + ' $CONTFSVolHome/$VOLDIR/' + dirname + '/;\\')
      write_line('ln -s $CONTFSVolHome/$VOLDIR/' + path + ' /home/' + path)
      n += 1     
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_data_permissions
    write_line('#Data Permissions')
    write_line('')
    write_line('RUN /usr/sbin/usermod -u $data_uid data-user;\\')
    write_line('chown -R $data_uid.$data_gid /home/app /home/fs ;\\')
    write_line('chmod -R 770 /home/fs')    
  end

  def write_run_install_script
    write_line('WorkDir /home/')
    write_line('#Setup templates and run installer')
    write_line('RUN bash /home/setup.sh')    
  end

  def write_database_seed
    if @blueprint_reader.database_seed.nil? == false
      seed_file = File.new(@blueprint_reader.get_basedir + '/home/database_seed', 'w')
      seed_file.write(@blueprint_reader.database_seed)
      seed_file.close
    end
  end

  def write_persistant_files
    write_line('#Persistant Files')
    log_build_output('set setup_env')
    src_paths = @blueprint_reader.persistant_files[:src_paths]
    #      dest_paths =  @blueprint_reader.persistant_files[:dest_paths]
    return if src_paths.nil?
    src_paths.each do |path|
      #          path = dest_paths[n]
      p :path
      p path
      dir = File.dirname(path)
      p :dir
      p dir
      if dir.is_a?(String) == false || dir.length == 0 || dir == '.' || dir == '..'
        dir = 'app/'
      end
      p :dir
      p dir
      write_line('')
      write_line('RUN mkdir -p /home/' + dir + ';\\')
      write_line('  if [ ! -f /home/' + path + ' ];\\')
      write_line('    then \\')
      write_line('      touch  /home/' + path + ';\\')
      write_line('    fi;\\')
      write_line('  mkdir -p $CONTFSVolHome/$VOLDIR/' + dir + ';\\')
      write_line('\\')
      write_line('   mv /home/' + path + ' $CONTFSVolHome/$VOLDIR' + '/' + dir + ';\\')
      write_line('    ln -s $CONTFSVolHome/$VOLDIR/' + path + ' /home/' + path)
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_file_service
    write_line('#File Service')
    write_line('#FS Env')
    @blueprint_reader.volumes.each_value do |vol|
      dest = File.basename(vol.remotepath)         
      write_line('RUN mkdir -p $CONTFSVolHome/' + dest)      
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_sed_strings
    n = 0
    write_line('#Sed Strings')
    @blueprint_reader.sed_strings[:src_file].each do |src_file|
      # src_file = @sed_strings[:src_file][n]
      dest_file = @blueprint_reader.sed_strings[:dest_file][n]
      sed_str = @blueprint_reader.sed_strings[:sed_str][n]
      tmp_file = @blueprint_reader.sed_strings[:tmp_file][n]
      write_line('')
      write_line('RUN cat ' + src_file + " | sed \"" + sed_str + "\" > " + tmp_file + ' ;\\')      
      write_line('     cp ' + tmp_file + ' ' + dest_file)      
      n += 1
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_rake_list
    write_line('#Rake Actions')
    @blueprint_reader.rake_actions.each do |rake_action|
      rake_cmd = rake_action[:action]
      if @builder.first_build == false && rake_action[:always_run] == false
        next
      end
      if rake_cmd.nil? == false
        write_line('RUN  /usr/local/rbenv/shims/bundle exec rake ' + rake_cmd)        
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_os_packages
    packages = ''
    write_line('#OS Packages')
    @blueprint_reader.os_packages.each do |package|
      if package.nil? == false
        packages = packages + package + ' '
      end
    end
    if packages.length > 1
      write_line('RUN apt-get install -y ' + packages)
      
    end
    # FIXME: Wrong spot
   return false if @blueprint_reader.worker_ports.nil?  
    @blueprint_reader.worker_ports.each do |port|
      write_line('EXPOSE ' + port.port.to_s)      
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def deploy_dir
    SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework
  end

  def build_dir
    @blueprint_reader.get_basedir
  end

  def insert_framework_frag_in_dockerfile(frag_name)
    log_build_output(frag_name)
    write_line('#Framework Frag')
    frame_build_docker_frag = File.open(build_dir + '/Dockerfile.' + frag_name)
    builder_frag = frame_build_docker_frag.read
    @docker_file.write(builder_frag)    
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def chown_home_app
    write_line('#Chown App Dir')
    log_build_output('Dockerfile:Chown')
    write_line('RUN if [ ! -d /home/app ];\\')
    write_line('  then \\')
    write_line('    mkdir -p /home/app ;\\')
    write_line('  fi;\\')
    write_line(' mkdir -p /home/fs ; mkdir -p /home/fs/local ;\\')
    write_line(' chown -R $ContUser /home/app /home/fs /home/fs/local')    
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_worker_commands
    write_line('#Worker Commands')
    log_build_output('Dockerfile:Worker Commands')
    scripts_path = @blueprint_reader.get_basedir + '/home/engines/scripts/'
    if Dir.exist?(scripts_path) == false
      FileUtils.mkdir_p(scripts_path)
    end
    if @blueprint_reader.worker_commands.nil? == false && @blueprint_reader.worker_commands.length > 0
      cmdf = File.open(scripts_path + 'pre-running.sh', 'w')
      if !cmdf
        puts('failed to open ' + scripts_path + 'pre-running.sh')
        exit
      end
      cmdf.chmod(0755)
      cmdf.puts('#!/bin/bash')
      cmdf.puts('cd /home/app')
      @blueprint_reader.worker_commands.each do |command|
        cmdf.puts(command)
      end
      cmdf.close
      File.chmod(0755, scripts_path + 'pre-running.sh')
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end



  def write_write_permissions_single
    write_line('')
    write_line('#Write Permissions Non Recursive')
    log_build_output('Dockerfile:Write Permissions Non Recursive')
    if @blueprint_reader.single_chmods.nil? == true
      return
    end
    @blueprint_reader.single_chmods.each do |path|
      if path.nil? == false
        write_line('RUN if [ ! -f /home/app/' + path + ' ];\\')
        write_line('   then \\')
        write_line('   mkdir -p  `dirname /home/app/' + path + '`;\\')
        write_line('   touch  /home/app/' + path + ';\\')
        write_line('     fi;\\')
        write_line('  chown $ContUser /home/app/' + path + ';\\')
        write_line('   chmod  775 /home/app/' + path)        
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_write_permissions_recursive
    write_line('#Write Permissions  Recursive')
    write_line('')
    log_build_output('Dockerfile:Write Permissions Recursive')
    if @blueprint_reader.recursive_chmods.nil? == true
      return
    end
    @blueprint_reader.recursive_chmods.each do |directory|
      if directory.nil? == false
        write_line('RUN if [ -h  /home/app/' + directory + ' ] ;\\')
        write_line('    then \\')
        write_line('    dest=`ls -la /home/app/' + directory + " |cut -f2 -d\'>\'`;\\")
        write_line('    chmod -R gu+rw $dest;\\')
        write_line('  elif [ ! -d /home/app/' + directory + ' ] ;\\')
        write_line('    then \\')
        write_line("       mkdir  -p \'/home/app/" + directory + "\';\\")
        write_line("      chown $data_uid  \'/home/app/" + directory + "\';\\")
        write_line("       chmod -R gu+rw \'/home/app/" + directory + "\';\\")
        write_line('  else\\')
        write_line("   chmod -R gu+rw \"/home/app/" + directory + "\";\\")
        write_line('     for dir in `find  /home/app/' + directory  + ' -type d  `;\\')
        write_line('       do\\')
        write_line("           adir=`echo $dir | sed \"/ /s//_+_/\" |grep -v _+_` ;\\")
        write_line('            if test -n $adir;\\')
        write_line('                then\\')
        write_line('                      dirs=`echo $dirs $adir`;\\')
        write_line('                fi;\\')
        write_line('       done;\\')
        write_line(' if test -n \'$dirs\' ;\\')
        write_line('      then\\')
        write_line('      chmod gu+x $dirs  ;\\')
        write_line('fi;\\')
        write_line('fi')        
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_app_archives
    write_line('#App Archives')
    log_build_output('Dockerfile:App Archives')
    # n=0
    #        srcs=String.new
    #        names=String.new
    #        locations=String.new
    #        extracts=String.new
    #        dirs=String.new
    write_line('')
    @blueprint_reader.archives_details.each do |archive_details|
      arc_src = archive_details[:source_url]
      arc_name = archive_details[:package_name]
      arc_loc = archive_details[:destination]
      arc_extract = archive_details[:extraction_command]
      arc_dir = archive_details[:path_to_extracted]
      p '_+_+_+_+_+_+_+_+_+_+_'
      p archive_details
      p arc_src + '_'
      p arc_name + '_'
      p arc_loc + '_'
      p arc_extract + '_'
      p arc_dir + '|'
      set_user('0')
      if arc_loc == './' || arc_loc == '.' || arc_loc == '/' || arc_loc == ''
        arc_loc = ''
      else
        if arc_loc.end_with?('/')
          arc_loc = arc_loc.chop # note not String#chop
        end
        if arc_loc.start_with?('/') == false
          arc_loc = '/' + arc_loc
        end
        write_line('RUN mkdir -p  /home/app')        
      end
      if arc_extract == 'git'
        write_line('WORKDIR /tmp')        
        write_line('RUN git clone ' + arc_src + ' --depth 1 ')        
        set_user('0')
        write_line('RUN mv  ' + arc_dir + ' /home/app' + arc_loc)        
        set_user('$ContUser')
      else
        step_back = false
        if arc_dir.nil? == true || arc_dir == ''
          step_back = true
          write_line('RUN   mkdir /tmp/app')          
          arc_dir = '/tmp/app'
          write_line('WORKDIR /tmp/app')         
        else
          write_line('WORKDIR /tmp')
          
        end
        write_line('RUN   wget  -O \'' + arc_name + '\' \'' + arc_src + '\' ;\\')
        if arc_extract.nil? == false && arc_extract != ''
          write_line(' ' + arc_extract + ' \'' + arc_name + '\' ;\\') # + '\'* 2>&1 > /dev/null ')
          write_line(' rm \'' + arc_name + '\'')
        else
          arc_dir = arc_name
          write_line('echo') # step past the next shell line implied by preceeding ;
        end
        set_user('0')
        if step_back == true
          write_line('WORKDIR /tmp')         
        end
        if arc_loc.start_with?('/home/app') == true || arc_loc.start_with?('/home/local') == true
          dest_prefix = ''
        else
          dest_prefix = '/home/app'
        end
        write_line('run   if test ! -d ' + arc_dir + ' ;\\')
        write_line('       then\\')
        write_line(' mkdir -p ' + dest_prefix + '/' + arc_loc + ' ;\\')
        write_line(' fi;\\')
        if dest_prefix != '' && dest_prefix != '/home/app'
          write_line(' mkdir -p ' + dest_prefix + ' ;\\')
        end
        write_line(' mv ' + arc_dir + ' ' + dest_prefix + arc_loc)       
        #          first_archive = false
        set_user('$ContUser')
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_container_user
    write_line('#Container Data User')
    log_build_output('Dockerfile:User')
    # FIXME: needs to by dynamic
    write_line('ENV data_gid ' + @blueprint_reader.data_uid)    
    write_line('ENV data_uid ' + @blueprint_reader.data_gid)    
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_stack_env
    log_build_output('Dockerfile:Stack Environment')
    write_line('#Stack Env')
    # stef = File.open(get_basedir + '/home/stack.env','w')
    write_line('')
    write_line('#Stack Env')
    write_line('ENV Memory ' + @blueprint_reader.memory.to_s)    
    write_line('ENV Hostname ' + @hostname)    
    write_line('ENV Domainname ' + @domain_name)    
    write_line('ENV fqdn ' + @hostname + '.' + @domain_name)    
    write_line('ENV FRAMEWORK ' + @blueprint_reader.framework)    
    write_line('ENV RUNTIME ' + @blueprint_reader.runtime)    
    write_line('ENV PORT ' + @web_port.to_s)    
    wports = ''
    n = 0
    return false if @blueprint_reader.worker_ports.nil?
    @blueprint_reader.worker_ports.each do |port|
      if n < 0
        wports += ' '
      end
      write_line('EXPOSE ' + port.port.to_s)      
      wports += port.port.to_s
      n += 1
    end
    if wports.length > 0
      write_line('ENV WorkerPorts ' + '\'' + wports +'\'')      
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_pear_modules
    write_line('#OPear modules ')
    log_build_output('Dockerfile:Pear modules ')
    if @blueprint_reader.pear_modules.count > 0
      write_line('RUN   wget http://pear.php.net/go-pear.phar;\\')
      write_line('  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\')
      write_line('  php go-pear.phar')      
      @blueprint_reader.pear_modules.each do |pear_mod|
        if pear_mod.nil? == false
          # for pear
          # write_line('RUN  pear install pear_mod ' + pear_mod )
          # for pecl
          write_line('RUN  pear install  ' + pear_mod)          
        end
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_pecl_modules
    write_line('#Pecl modules ')
    log_build_output('Dockerfile:Pecl modules ')
    if @blueprint_reader.pecl_modules.count > 0
      write_line('RUN   wget http://pear.php.net/go-pear.phar;\\')
      write_line('  echo suhosin.executor.include.whitelist = phar >>/etc/php5/conf.d/suhosin.ini ;\\')
      write_line('  php go-pear.phar')
      
      @blueprint_reader.pecl_modules.each do |pecl_mod|
        if pecl_mod.nil? == false
          write_line('RUN  pecl install  ' + pecl_mod)
        end
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_line(line)
    @docker_file.puts(line)
    count_layer unless line.start_with?('#') || line.end_with?('\\') # or whitespace only    
  end
  
  def set_user(user)
    write_line('User ' + user)   
  end
end
