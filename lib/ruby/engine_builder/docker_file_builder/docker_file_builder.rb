class DockerFileBuilder
  require_relative 'framework_modules.rb'
  include FrameworkModules
  def initialize(reader, build_params, webport, builder)
    @build_params = build_params
    @hostname = @build_params[:host_name]
    @domain_name = @build_params[:domain_name]
    @web_port = webport
    @blueprint_reader = reader
    @builder = builder
    @docker_file = File.open(@builder.basedir + '/Dockerfile', 'a')
    @layer_count = 0
    @env_file = File.new(@builder.basedir + '/build.env', 'w+')
    # this should be read as it is framework dep
    @max_layers = 75
  end

  def log_build_output(line)
    @builder.log_build_output(line)
  end

  def log_build_errors(line)
    @builder.log_build_errors(line)
  end

  def count_layer
    @layer_count += 1
    if @layer_count > @max_layers
      raise EngineBuilderException.new(error_hash("More than 75 layers!"))
    end
  end

  def write_files_for_docker
    @in_run = false
    write_line('')
    write_environment_variables
    write_stack_env
    write_file_service
    
    write_run_start
     write_repos
     write_os_packages
     write_modules
    write_run_end
    
    write_user_local = true
    setup_user_local if write_user_local
    set_user('0')
    
    write_run_start
     write_app_archives
     write_app_templates
    write_run_end
    
    set_user('$ContUser')
    write_container_user
    set_user('0')
    chown_home_app
    set_user('$ContUser')
    write_database_seed
    # write_worker_commands

    write_run_start
     write_sed_strings
     write_persistent_dirs
     write_persistent_files
    write_run_end

    insert_framework_frag_in_dockerfile('builder.mid.tmpl')
    write_rake_list
    set_user('0')
    write_permissions
    write_run_line('mkdir -p /home/fs/local/')

    set_user('$ContUser') unless @blueprint_reader.framework == 'docker'

    write_run_install_script
    set_user('0')
    setup_persitant_app if @build_params[:app_is_persistent]
    prepare_persitant_source
    write_data_permissions
    finalise_files
  end

  def write_app_templates
    write_build_script('install_templates.sh ')
  end

  def setup_user_local
    write_run_start()
    write_run_line('ln -s /usr/local/ /home/local')
    write_run_line('chown -R $ContUser /usr/local/ ')
    write_run_end()
  end

  def finalise_docker_file
    write_build_script('_finalise_environment.sh')
    if @blueprint_reader.respond_to?(:continuous_deployment)
      log_build_output("Setting up Continuos Deployment:" + @blueprint_reader.continuous_deployment.to_s ) if @blueprint_reader.continuous_deployment
      write_cd if @blueprint_reader.continuous_deployment
    end
    insert_framework_frag_in_dockerfile('builder.end.tmpl')
    write_line('')
    write_volume('/home/fs/')
    write_clear_env_variables
    @docker_file.close
  end

  def write_cd
    write_run_start()
    write_run_line('chown -R $ContUser /home/app')
    write_run_line('chmod g+w -R /home/app')
    write_run_end()

  end

  def finalise_files
    finalise_docker_file
    @env_file.close
  end

  def prepare_persitant_source
    write_run_line('mv /home/fs /home/fs_src')
    write_volume('/home/fs_src/')
  end

  def setup_persitant_app
    write_run_line('cp -rp /home/app /home/app_src')
    write_volume('/home/app_src/')
  end

  def write_permissions
    write_run_start()
    write_write_permissions_recursive # recursive firs (as can use to create blank dir)
    write_write_permissions_single
    write_run_end()
  end

  def write_modules
    write_pear_modules
    write_php_modules
    write_npm_modules
    write_lua_modules
    write_pecl_modules
    write_apache_modules
  end

  def write_clear_env_variables
    write_line('#Clear env')
    return true if @blueprint_reader.environments.nil?
    @blueprint_reader.environments.each do |env|
      write_env(env.name, '.') if env.build_time_only
    end
  end

  def write_environment_variables
    return true if @blueprint_reader.environments.nil?
    write_line('#Environment Variables')
    @blueprint_reader.environments.each do |env|
      write_line('#Blueprint ENVs')
      #  if env.value && env.value.nil? == false && env.value.to_s.length > 0
      #   SystemDebug.debug(SystemDebug.builder, :env_val, env.value)
      # env.value.gsub!(/ /, "\\ ")
      # end
      write_env(env.name,env.value.to_s) if env.value.nil? == false && env.value.to_s.length > 0 # env statement must have two arguments
    end
    write_env('WWW_DIR', @blueprint_reader.web_root.to_s) unless @blueprint_reader.web_root.nil?
    # write_locale_env
  end

  def write_persistent_dirs
    log_build_output('setup persistent Dirs')
    return true if @blueprint_reader.persistent_dirs.nil?
    paths = ''
    write_run_line('#Persistant Dirs')
    @blueprint_reader.persistent_dirs.each do |path|
      path.chomp!('/')
      paths += path + ' ' unless path.nil?
    end
    write_build_script('persistent_dirs.sh  ' + paths)
  end

  def write_data_permissions
    write_run_line('#Data Permissions')
    write_build_script('set_data_permissions.sh')
  end

  def write_run_install_script
    write_run_line('WORKDIR /home/')
    write_run_line('#RUN framework and custom installer')
    write_run_line('bash /home/setup.sh')
    true
  end

  def write_database_seed
    if @blueprint_reader.database_seed.nil? == false && @blueprint_reader.database_seed != ''
      ConfigFileWriter.write_templated_file(@builder.templater, @builder.basedir + '/home/database_seed', @blueprint_reader.database_seed)
    end
  end

  def write_persistent_files
    write_run_line('#Persistant Files')
    return true if @blueprint_reader.persistent_files.nil?
    log_build_output('set setup_env')
    paths = ''
    src_paths = @blueprint_reader.persistent_files[:src_paths]
    return if src_paths.nil?
    src_paths.each do |path|
      dir = File.dirname(path)
      file = File.basename(path)
      SystemDebug.debug(SystemDebug.builder, :dir, dir)
      if dir.is_a?(String) == false || dir.length == 0 || dir == '.' || dir == '..'
        path = 'app/' + file
      end
      paths += path + ' '
    end
    write_build_script('persistent_files.sh   ' + paths)
  end

  def write_file_service
    write_line('#File Service')
    if  @builder.volumes.count >0
      @builder.volumes.each_value do |vol|
        dest = File.basename(vol[:remotepath])
        write_line('#FS Env')
        # write_line('RUN mkdir -p $CONTFSVolHome/' + dest)
        # write_line('RUN mkdir -p $CONTFSVolHome/$VOLDIR' )
      end
    end
  end

  def write_sed_strings
    n = 0
    write_run_line('#Sed Strings')
    return true if @blueprint_reader.sed_strings.nil?

    @blueprint_reader.sed_strings[:src_file].each do |src_file|
      # src_file = @sed_strings[:src_file][n]
      dest_file = @blueprint_reader.sed_strings[:dest_file][n]
      sed_str = @blueprint_reader.sed_strings[:sed_str][n]
      tmp_file = @blueprint_reader.sed_strings[:tmp_file][n]
      write_run_line('cat ' + src_file + " | sed \"" + sed_str + "\" > " + tmp_file)
      write_run_line('cp ' + tmp_file + ' ' + dest_file)
      n += 1
    end

  end

  def write_repos
    return if @blueprint_reader.external_repositories.nil? || @blueprint_reader.external_repositories.empty?
    write_run_line('#Repositories')
    @blueprint_reader.external_repositories.each do |repo|
      next unless repo.key?(:source)
      write_run_line('add-apt-repository  -y  ' + repo[:source])
    end
    write_run_line('apt-get -y update ')
  end

  def write_os_packages
    packages = ''
    write_run_line('#OS Packages')
    return true if @blueprint_reader.os_packages.nil?
    @blueprint_reader.os_packages.each do |package|
      if package.nil? == false
        packages = packages + package + ' '
      end
    end
    if packages.length > 1
      write_run_line('apt-get install -y ' + packages)
    end
    # FIXME: Wrong spot
    #    return false if @blueprint_reader.mapped_ports.nil?
    #    @blueprint_reader.mapped_ports.each_value do |port|
    #      write_line('EXPOSE ' + port[:port].to_s)
    #    end
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
    frame_build_docker_frag.close
  end

  def chown_home_app
    write_run_line('#Chown App Dir')
    log_build_output('Dockerfile:Chown')
    write_build_script('chown_app_dir.sh  ')
  end

  def write_write_permissions_single
    write_run_line('#Write Permissions Non Recursive')
    log_build_output('Dockerfile:Write Permissions Non Recursive')
    return true if @blueprint_reader.single_chmods.nil? == true
    paths = ''
    @blueprint_reader.single_chmods.each do |path|
      paths += path + ' ' unless path.nil?
    end
    write_run_line('/build_scripts/write_permissions.sh ' + paths)
  end

  def write_write_permissions_recursive
    write_run_line('#Write Permissions  Recursive')
    log_build_output('Dockerfile:Write Permissions Recursive')
    return true if @blueprint_reader.recursive_chmods.nil? == true
    dirs = ''
    @blueprint_reader.recursive_chmods.each do |directory|
      dirs += directory + ' ' unless directory.nil?
    end
    write_run_line('/build_scripts/recursive_write_permissions.sh ' + dirs)
  end

  def write_app_archives
    return true if @blueprint_reader.archives_details.nil?
    write_run_line('#App Archives')
    log_build_output('Dockerfile:App Archives')
    @blueprint_reader.archives_details.each do |archive_details|
      next if archive_details[:extraction_command] == 'docker'
      source_url = archive_details[:source_url].to_s
      package_name = archive_details[:package_name].to_s
      destination = archive_details[:destination].to_s
      extraction_command = archive_details[:extraction_command].to_s
      path_to_extracted = archive_details[:path_to_extracted].to_s
      if destination == './' || destination == '/'
        destination = ''
      elsif destination.end_with?('/')
        arc_loc = destination.chop # note not String#chop
      end

      # Destination can be /opt/ /home/app /home/fs/ /home/local/
      # If none of teh above then it is prefixed with /home/app
      destination = '/home/app/' + destination.to_s  unless destination.start_with?('/opt') || destination.start_with?('/home/fs') || destination.start_with?('/home/app') || destination.start_with?('/home/local')
      destination = '/home/app' if destination.to_s == '/home/app/' || destination == '/'  || destination == './'  || destination == ''

      path_to_extracted ='/' if path_to_extracted.nil? || path_to_extracted == ''

      args = ' \'' + source_url + '\' '
      args += ' \'' + package_name + '\' '
      args += ' \'' + extraction_command + '\' '
      args += ' \'' + destination + '\' '
      args += ' \'' + path_to_extracted + '\' '
      write_run_line('/build_scripts/package_installer.sh ' + args)
    end
  end

  def write_container_user
    write_line('#Container Data User')
    log_build_output('Dockerfile:User')
    # FIXME: needs to by dynamic
    write_env('data_gid', @builder.data_gid.to_s)
    write_env('data_uid', @builder.data_uid.to_s)
  end

  def write_stack_env
    log_build_output('Dockerfile:Stack Environment')
    write_line('#Stack Env')
    write_line('')
    # write_env('Memory' ,@builder.memory.to_s)
    write_env('Hostname', @hostname)
    write_env('Domainname', @domain_name)
    write_env('fqdn', @hostname + '.' + @domain_name)
    write_env('FRAMEWORK', @blueprint_reader.framework)
    write_env('RUNTIME', @blueprint_reader.runtime)
    write_env('PORT', @web_port.to_s)
    wports = ''
    n = 0
    return false if @blueprint_reader.mapped_ports.nil?
    @blueprint_reader.mapped_ports.each_value do |port|
      if n < 0
        wports += ' '
      end
      write_expose(port[:port].to_s)
      count_layer
      wports += port[:port].to_s + ' '
      n += 1
    end
    if wports.length > 0
      write_env('WorkerPorts', wports)
    end
  end

  def write_volume(vol)
    write_line('VOLUME ' + vol.to_s)
    count_layer
  end

  def write_expose(port)
    write_line('EXPOSE ' + port)
    count_layer
  end

  def write_env(name, value, build_only = false)
    write_line('ENV ' + name.to_s  + " \'" + value.to_s + "\'")
    @env_file.puts(name.to_s  + '=' + "\'" + value.to_s  + "\'")
    count_layer
  end

  def write_run_line(cmd)
    unless @in_run == true
      if cmd.begin_with?('#')
        @docker_file.puts(cmd)
      else
        @docker_file.puts('RUN    ' + cmd)
        count_layer
      end
      return
    end
    if @first_line == true
      @docker_file.write("\\\n     " + cmd)
    else
      @docker_file.write(";\\\n     " + cmd)
    end
    @first_line = false
  end

  def write_run_start(comment = '')
    @in_run = true
    @first_line = true
    write_line("\n#Start of Run:" + comment.to_s)
    @docker_file.write('RUN ')
    count_layer
  end

  def write_run_end()
    write_line("\n#End of Run:\n\n")
    @in_run = false
  end

  def write_build_script(cmd)
    write_run_line('/build_scripts/' + cmd)    
  end

  def write_line(line)
    @docker_file.puts(line)

    #count_layer unless line.start_with?('#') || line.end_with?('\\') # or whitespace only
  end

  def set_user(user)
    write_line('USER ' + user)
    count_layer
  end
end
