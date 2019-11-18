class DockerFileBuilder
  require_relative 'archives.rb'

  include Archives

  require_relative 'persistence.rb'
  def initialize(reader, memento, webport, builder)
    @memento = memento
    @hostname = memento.host_name
    @domain_name = memento.domain_name
    @web_port = webport
    @blueprint_reader = reader
    @builder = builder
    @docker_file = File.open("#{@builder.basedir}/Dockerfile", 'a')
    @layer_count = 0
    #FIXME
    @env_file = File.new("#{@builder.basedir}/build.env", 'w+')
    # this should be read as it is framework dep
    @max_layers = 75
  end

  def log_build_output(mesg)
    @builder.log_build_output(mesg)
  end

  def write_files_for_docker
    @in_run = false
    write_environment_variables
    write_stack_env
    write_container_user
    write_file_service
    set_user('0')
    add_sudoers
    write_user_local = true
    setup_user_local if write_user_local
    write_repos
    write_os_packages
    write_modules
    write_app_archives
    write_permissions
    write_app_templates
    set_user('0')
    chown_home_app
    set_user('$ContUser')
    write_database_seed
    write_sed_strings
    write_persistent_dirs
    write_persistent_files
    insert_framework_frag_in_dockerfile('builder.mid.tmpl')
    write_rake_list
    set_user('0')
    write_run_line('mkdir -p /home/fs/local/')
    set_user('$ContUser') unless @blueprint_reader.framework == 'docker'
    write_run_install_script
    set_user('0')
    setup_persitant_app if @user_params[:app_is_persistent]
    prepare_persitant_source
    write_data_permissions
    finalise_files
  end

  private
  require_relative 'framework_modules.rb'
  include FrameworkModules

  require_relative 'docker_commands.rb'
  require_relative 'file_writer.rb'

  def add_sudoers
    if @blueprint_reader.respond_to?('sudo_list')
      if @blueprint_reader.sudo_list.is_a?(Array)
        copyin_sudoer_file if @blueprint_reader.sudo_list.length > 0
      end
    end
  end

  def write_app_templates
    write_build_script('install_templates.sh ')
  end

  def setup_user_local
    #  write_run_start()
    write_build_script('set_cont_user.sh')
    write_run_line('ln -s /usr/local/ /home/local')
    write_run_line('chown -R $ContUser /usr/local/ ')

  end

  def finalise_docker_file
    write_build_script('_finalise_environment.sh')
    if @blueprint_reader.respond_to?(:continuous_deployment)
      log_build_output("Setting up Continuos Deployment:#{@blueprint_reader.continuous_deployment}" ) if @blueprint_reader.continuous_deployment
      write_cd if @blueprint_reader.continuous_deployment
    end
    write_run_end if @in_run == true
    insert_framework_frag_in_dockerfile('builder.end.tmpl')
    write_volume('/home/fs/')
    write_clear_env_variables
    write_system_dockerfile_end
    @docker_file.close
  end

  def write_system_dockerfile_end
    insert_framework_frag_in_dockerfile('builder.system.end.tmpl')
  end

  def write_cd
    write_run_line('chown -R $ContUser /home/app')
    write_run_line('chmod g+w -R /home/app')
  end

  def finalise_files
    finalise_docker_file
    @env_file.close
  end

  def prepare_persitant_source
    write_build_script('prepare_persitent_source.sh')
    write_volume('/home/fs_src/')
  end

  def setup_persitant_app
    write_run_line('cp -rp /home/app /home/app_src')
    write_volume('/home/app_src/')
  end

  def write_permissions
    write_write_permissions_recursive # recursive firs (as can use to create blank dir)
    write_write_permissions_single
  end

  def write_modules
    write_pear_modules
    write_php_modules
    write_python_modules
    write_npm_modules
    write_lua_modules
    write_pecl_modules
    write_apache_modules
  end

  def write_clear_env_variables
    unless @blueprint_reader.environments.nil?
      write_comment('#Clear env')
      @blueprint_reader.environments.each do |env|
        write_env(env.name, '.') if env.build_time_only
      end
    end
  end

  def write_environment_variables
    unless @blueprint_reader.environments.nil?
      write_comment('#Environment Variables')
      @blueprint_reader.environments.each do |env|
        write_env(env.name,env.value.to_s) if env.value.nil? == false && env.value.to_s.length > 0 # env statement must have two arguments
      end
      write_env('WWW_DIR', @blueprint_reader.web_root.to_s) unless @blueprint_reader.web_root.nil?
    end
  end

  def write_data_permissions
    write_comment('#Data Permissions')
    write_build_script('set_data_permissions.sh')
  end

  def write_run_install_script
    write_work_dir('/home/')
    write_comment('#RUN framework and custom installer')
    write_run_line('bash /home/setup.sh')
    true
  end

  def write_database_seed
    unless @blueprint_reader.database_seed.nil? == false || @blueprint_reader.database_seed != ''
      ConfigFileWriter.write_templated_file(@builder.templater, @builder.basedir + '/home/database_seed', @blueprint_reader.database_seed)
    end
  end

  def write_file_service
    unless @builder.volumes.empty?
      write_comment('#File Service')
      @builder.volumes.each_value do |vol|
        dest = File.basename(vol[:remotepath])
        write_comment('#FS Env')
      end
    end
  end

  def write_sed_strings
    unless @blueprint_reader.sed_strings.nil?
      n = 0
      write_comment('#Sed Strings')
      @blueprint_reader.sed_strings[:src_file].each do |src_file|
        # src_file = @sed_strings[:src_file][n]
        dest_file = @blueprint_reader.sed_strings[:dest_file][n]
        sed_str = @blueprint_reader.sed_strings[:sed_str][n]
        tmp_file = @blueprint_reader.sed_strings[:tmp_file][n]
        write_run_line("cat #{src_file} | sed \"#{sed_str}\" > #{tmp_file}")
        write_run_line("cp #{tmp_file} #{dest_file}")
        n += 1
      end
    end
  end

  def write_repos
    if @blueprint_reader.respond_to?(:external_repositories)
      unless  @blueprint_reader.external_repositories.nil? || @blueprint_reader.external_repositories.empty?
        write_comment('#Repositories')
        @blueprint_reader.external_repositories.each do |repo|
          next unless repo.key?(:source)
          if repo.key?(:key)
            unless repo[:key].nil?
              write_run_line("wget -qO - #{repo[:key]} | apt-key add -")
            end
          end
        write_run_line("add-apt-repository  -y #{repo[:source]}")
        end
        write_run_line('apt-get -y update ')
      end
    end
  end

  def write_os_packages
    unless @blueprint_reader.os_packages.nil?
      packages = ''
      write_comment('#OS Packages')
      @blueprint_reader.os_packages.each do |package|
        if package.nil? == false
          packages = packages + package + ' '
        end
      end
      if packages.length > 1
        write_run_line("apt-get install -y #{packages}")
      end
    end
  end

  def deploy_dir
    "#{SystemConfig.DeploymentTemplates}/#{@blueprint_reader.framework}"
  end

  def build_dir
    @builder.basedir
  end

  def chown_home_app
    write_comment('#Chown App Dir')
    log_build_output('Dockerfile:Chown')
    write_build_script('chown_app_dir.sh  ')
  end

  def write_write_permissions_single
    unless @blueprint_reader.single_chmods.nil? == true
      write_comment('#Write Permissions Non Recursive')
      log_build_output('Dockerfile:Write Permissions Non Recursive')
      paths = ''
      @blueprint_reader.single_chmods.each do |path|
        paths += path + ' ' unless path.nil?
      end
      write_run_line("/build_scripts/write_permissions.sh #{paths}")
    end
  end

  def write_write_permissions_recursive
    unless @blueprint_reader.recursive_chmods.nil?
      write_comment('#Write Permissions  Recursive')
      log_build_output('Dockerfile:Write Permissions Recursive')
      dirs = ''
      @blueprint_reader.recursive_chmods.each do |directory|
        dirs += directory + ' ' unless directory.nil?
      end
      write_run_line("/build_scripts/recursive_write_permissions.sh #{dirs}")
    end
  end

  def write_container_user
    write_run_end if @in_run == true
    write_comment('#Container Data User')
    log_build_output('Dockerfile:User')
    # FIXME: needs to by dynamic
    write_env('cont_uid', @builder.cont_user_id)
    write_env('data_gid', @builder.data_gid.to_s)
    write_env('data_uid', @builder.data_uid.to_s)
  end

  def write_stack_env
    write_run_end if @in_run == true
    log_build_output('Dockerfile:Stack Environment')
    write_comment('#Stack Env')
    write_line('')
    write_env('Hostname', @hostname)
    write_env('Domainname', @domain_name)
    write_env('fqdn', @hostname + '.' + @domain_name)
    write_env('FRAMEWORK', @blueprint_reader.framework)
    write_env('RUNTIME', @blueprint_reader.runtime)
    write_env('PORT', @web_port.to_s)
    wports = ''
    n = 0
    unless @blueprint_reader.mapped_ports.nil?
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
  end

end
