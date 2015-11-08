class DockerFileBuilder
  require_relative 'framework_modules.rb'
  include FrameworkModules
  
  def initialize(reader, build_params, webport, builder)
    @build_params = build_params
    @hostname = @build_params[:host_name]
    # @container_name = containername
    @domain_name = @build_params[:domain_name]
    @web_port = webport
    @blueprint_reader = reader
    @builder = builder
    @docker_file = File.open(@builder.basedir + '/Dockerfile', 'a')
    @layer_count = 0
    @env_file = File.new(@builder.basedir + '/build.env','w+')
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
      @builder.log_build_errors("More than 75 layers!")
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
    set_user('0')
    write_app_templates
    set_user('$ContUser')
    write_container_user
    set_user('0')
    chown_home_app
    set_user('$ContUser')
    write_database_seed
   # write_worker_commands
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
    set_user('$ContUser')
    write_run_install_script
    set_user('0')
    setup_persitant_app if @build_params[:app_is_persistant]
    prepare_persitant_source 
    write_data_permissions
    finalise_files
    return true
  end
  
  def write_app_templates
    write_build_script('install_templates.sh ')
  end
  
  def setup_user_local  
    write_line('RUN ln -s /usr/local/ /home/local;\\')
    write_line('     chown -R $ContUser /usr/local/')
  end
  
  def finalise_docker_file
   write_build_script('_finalise_environment.sh')
    insert_framework_frag_in_dockerfile('builder.end.tmpl')
    write_line('')
    write_line('VOLUME /home/fs/')    
    write_clear_env_variables
    @docker_file.close
  end
  
  def finalise_files
    finalise_docker_file
    @env_file.close
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
        @env_file.puts(env.name + '=' + env.value.to_s) 
      end
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_persistant_dirs
    log_build_output('setup persistant Dirs')
    paths = ''
    write_line('#Persistant Dirs')
    @blueprint_reader.persistant_dirs.each do |path|
      path.chomp!('/')
      paths += path + ' ' unless path.nil?   
    end
    write_build_script('persistant_dirs.sh  ' + paths)
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_data_permissions
    write_line('#Data Permissions')
    write_build_script('set_data_permissions.sh')       
  end

  def write_run_install_script
    write_line('WorkDir /home/')
    write_line('#run framework and custom installer')
    write_line('RUN bash /home/setup.sh')    
  end

  def write_database_seed
    if @blueprint_reader.database_seed.nil? == false
      seed_file = File.new(@builder.basedir + '/home/database_seed', 'w')
      seed_file.write(@blueprint_reader.database_seed)
      seed_file.close
    end
  end

  def write_persistant_files
    write_line('#Persistant Files')
    log_build_output('set setup_env')
    paths = ''
    src_paths = @blueprint_reader.persistant_files[:src_paths]
    return if src_paths.nil?
    src_paths.each do |path|
      dir = File.dirname(path)
      file = File.basename(path)
      p :dir
      p dir
      if dir.is_a?(String) == false || dir.length == 0 || dir == '.' || dir == '..'
        path = 'app/' + file
      end
      paths += path + ' '
    end
    write_build_script('persistant_files.sh   ' + paths)
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_file_service
    write_line('#File Service')
    write_line('#FS Env')
    @builder.volumes.each_value do |vol|      
      dest = File.basename(vol.remotepath)         
      write_line('RUN mkdir -p $VOLDIR/' + dest)      
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
   return false if @blueprint_reader.mapped_ports.nil?  
    @blueprint_reader.mapped_ports.each do |port|
      write_line('EXPOSE ' + port.port.to_s)      
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def deploy_dir
    SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework
  end

  def build_dir
    @builder.basedir
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
    write_build_script('chown_app_dir.sh  ')  
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  


  def write_write_permissions_single
    write_line('')
    write_line('#Write Permissions Non Recursive')
    log_build_output('Dockerfile:Write Permissions Non Recursive')
    return if @blueprint_reader.single_chmods.nil? == true
    paths = ''
    @blueprint_reader.single_chmods.each do |path|
      paths += path + ' ' unless path.nil? 
    end
    write_build_script('write_permissions.sh ' + paths) 
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_write_permissions_recursive
    write_line('#Write Permissions  Recursive')
    log_build_output('Dockerfile:Write Permissions Recursive')
    return if @blueprint_reader.recursive_chmods.nil? == true
    dirs = ''
    @blueprint_reader.recursive_chmods.each do |directory|      
      dirs += directory + ' ' unless directory.nil? 
    end
    write_build_script('recursive_write_permissions.sh ' + dirs) 
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_app_archives
    write_line('#App Archives')
    log_build_output('Dockerfile:App Archives')
    write_line('')
    set_user('0')
    @blueprint_reader.archives_details.each do |archive_details|
      source_url = archive_details[:source_url].to_s
      package_name = archive_details[:package_name].to_s
      destination = archive_details[:destination].to_s
      extraction_command = archive_details[:extraction_command].to_s
      path_to_extracted = archive_details[:path_to_extracted].to_s


      # Destination can be /opt/ /home/app /home/fs/ /home/local/
      # If none of teh above then it is prefixed with /home/app
      destination = '/home/app/' + destination  unless destination.starts_with?('/opt') || destination.starts_with?('/home/fs') || destination.starts_with?('/home/app') || destination.starts_with?('/home/local')
      destination = '/home/app' if destination == '/home/app/'  || destination == '/'  || destination == './'  
        
      
       path_to_extracted ='/' if path_to_extracted.nil? || path_to_extracted == ''

      args = ' \'' + source_url + '\' '
      args += ' \'' + package_name + '\' '
      args += ' \'' + extraction_command + '\' '
      args += ' \'' + destination + '\' '
      args += ' \'' + path_to_extracted + '\' '
          write_build_script('package_installer.sh' + args )
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  def write_container_user
    write_line('#Container Data User')
    log_build_output('Dockerfile:User')
    # FIXME: needs to by dynamic
    write_line('ENV data_gid ' + @builder.data_gid.to_s)    
    write_line('ENV data_uid ' + @builder.data_uid.to_s)  
    @env_file.puts('data_gid' + '=' + @builder.data_gid.to_s) 
    @env_file.puts('data_uid' + '=' + @builder.data_uid.to_s) 
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
    return false if @blueprint_reader.mapped_ports.nil?
    @blueprint_reader.mapped_ports.each do |port|
      if n < 0
        wports += ' '
      end
      write_line('EXPOSE ' + port.port.to_s)      
      wports += port.port.to_s + ' '
      n += 1
    end
    if wports.length > 0
      write_line('ENV WorkerPorts ' + '\'' + wports +'\'')   
      @env_file.puts('WorkerPorts=' + '\'' + wports +'\'')
      env.value.to_s
    end
  rescue Exception => e
    SystemUtils.log_exception(e)
  end

  
  def write_build_script(cmd)
    write_line('RUN  /build_scripts/' + cmd)
  end

  def write_line(line)
    @docker_file.puts(line)
    count_layer unless line.start_with?('#') || line.end_with?('\\') # or whitespace only    
  end
  
  def set_user(user)
    write_line('User ' + user)   
  end
end
