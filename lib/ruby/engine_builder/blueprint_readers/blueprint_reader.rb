class BluePrintReader
  def initialize(contname, blue_print, builder)

    @builder = builder
    @container_name = contname
    @blueprint = blue_print
    @web_port = nil
    @services = []
    @os_packages = []
  end

  attr_reader :persistent_files,
  :persistent_dirs,
  :mapped_ports,
  :environments,
  :recursive_chmods,
  :single_chmods,
  :framework,
  :runtime,
  :memory,
  :rake_actions,
  :os_packages,
  :pear_modules,
  :apache_modules,
  :php_modules,
  :lua_modules,
  :pecl_modules,
  :npm_modules,
  :archives_details,
  :worker_commands,
  :cron_jobs,
  :sed_strings,
  :data_uid,
  :data_gid,
  :cron_job_list,
  :web_port,
  :services,
  :deployment_type,
  :database_seed,
  :blocking_worker,
  :web_root,
  :actionators,
  :base_image,
  :capabilities,
  :cont_user,
  :custom_start_script,
  :custom_stop_script,
  :custom_first_run_script,
  :custom_install_script,
  :custom_post_install_script,
  :template_files,
  :custom_php_inis,
  :apache_httpd_configurations,
  :apache_htaccess_files,
  :install_report_template,
  :schema

  
  def log_build_output(line)
    @builder.log_build_output(line)
  end

  def log_build_errors(line)
    @builder.log_build_errors(line)
  end

  def clean_path(path)
    # FIXME: remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any ' ' or ';' or '&' or '|' etc
    path
  end

  def process_blueprint
    log_build_output('Process BluePrint')
    read_services
    read_environment_variables
    read_os_packages
    read_lang_fw_values
    read_pkg_modules
    read_app_packages
    read_sql_seed
    read_write_permissions_recursive
    read_write_permissions_single
    read_worker_commands
    read_deployment_type
    read_sed_strings
    read_mapped_ports
    read_os_packages
    read_app_packages
    read_rake_list
    read_persistent_files
    read_persistent_dirs
    read_web_port_overide
    read_web_root
    read_scripts
    read_templates
    read_actionators
    read_custom_php_inis
    read_apache_httpd_configurations
    read_apache_htaccess_files
    read_install_report_template
  end

  def read_install_report_template
    @install_report_template = @blueprint[:software][:installation_report_template]
  end

  def read_apache_htaccess_files
    @apache_htaccess_files = @blueprint[:software][:apache_htaccess_files] if @blueprint[:software][:apache_htaccess_files].is_a?(Array)
  end

  def read_custom_php_inis
    @custom_php_inis = @blueprint[:software][:custom_php_inis] if @blueprint[:software][:custom_php_inis].is_a?(Array)
  end

  def read_apache_httpd_configurations
    @apache_httpd_configurations = @blueprint[:software][:apache_httpd_configurations] if  @blueprint[:software][:apache_httpd_configurations].is_a?(Array)
  end

  def read_templates
    @template_files = @blueprint[:software][:template_files] if @blueprint[:software][:template_files].is_a?(Array)
  end

  def read_scripts
    @custom_start_script =  @blueprint[:software][:custom_start_script].gsub(/\r/, '') if @blueprint[:software].key?(:custom_start_script)
    @custom_stop_script =  @blueprint[:software][:custom_stop_script].gsub(/\r/, '') if @blueprint[:software].key?(:custom_stop_script)
    @custom_install_script =  @blueprint[:software][:custom_install_script].gsub(/\r/, '') if @blueprint[:software].key?(:custom_install_script)
    @custom_post_install_script =  @blueprint[:software][:custom_post_install_script].gsub(/\r/, '') if  @blueprint[:software].key?(:custom_post_install_script)
  end

  def read_sql_seed
    if @blueprint[:software].key?(:database_seed_file) # && @blueprint[:software][:database_seed_file][:content].nil? == false
      database_seed_file = @blueprint[:software][:database_seed_file] #[:content]
      @database_seed = database_seed_file unless database_seed_file.nil?
    end
  end

  def read_web_root
    @web_root = @blueprint[:software][:web_root_directory] if @blueprint[:software].key?(:web_root_directory)
    SystemDebug.debug(SystemDebug.builder,  ' @web_root ',  @web_root)
  end

  def read_deployment_type
    @deployment_type = @blueprint[:software][:deployment_type]
  end

  def re_set_service(service_cnt, service_hash)
    @services[service_cnt] = service_hash
  end

  def read_web_port_overide
    if @blueprint[:software][:base].key?(:framework_port_override)
      @web_port = @blueprint[:software][:base][:framework_port_override]
    end
  end

  def read_persistent_dirs
    log_build_output('Read Persistant Dirs')
    @persistent_dirs = []
    pds = @blueprint[:software][:persistent_directories]
    if pds.is_a?(Array) # not an error just nada
      pds.each do |dir|
        dir[:volume_name] = @builder.templater.process_templated_string(dir[:volume_name])
        dir[:path] = clean_path(dir[:path])
        @persistent_dirs.push(dir)
      end
    end
  end

  def read_persistent_files
    log_build_output('Read Persistant Files')
    @persistent_files = []
    pfs = @blueprint[:software][:persistent_files]
    if pfs.is_a?(Array) # not an error just nada
      pfs.each do |file|
        file[:volume_name] = @builder.templater.process_templated_string(file[:volume_name])
        file[:path] = clean_path(file[:path])
        @persistent_files.push(file)
      end      
    end
      @persistent_files
  end

  def read_rake_list
    @rake_actions = []
    log_build_output('Read Rake List')
    if @blueprint[:software].key?(:framework_specific)
      rake_cmds = @blueprint[:software][:framework_specific][:rake_tasks]
      if rake_cmds.is_a?(Array) # not an error just nada
        rake_cmds.each do |rake_cmd|
          @rake_actions.push(rake_cmd)
        end
      end
    end
  end

  def read_services
    log_build_output('Read Services')
    STDERR.puts( ' BP ' + @blueprint[:software].to_s + "\n\n:" + @blueprint['software'].to_s  )
    STDERR.puts( 'service_configurations ' + @blueprint[:software][:service_configurations].to_s)
    services = @blueprint[:software][:service_configurations]
    if services.is_a?(Array) # not an error just nada
      services.each do |service|
        service[:publisher_namespace] = 'EnginesSystem' if service.key?(:publisher_namespace) == false || service[:publisher_namespace].nil?
        add_service(service)
      end
    end
  end

  def add_service(service_hash)
    SystemDebug.debug(SystemDebug.builder, :add_service, service_hash)
    @builder.templater.fill_in_dynamic_vars(service_hash)
    @services.push(service_hash)
  end

  def read_os_packages
    log_build_output('Read OS Packages')
    ospackages = @blueprint[:software][:system_packages]
    if ospackages.is_a?(Array) # not an error just nada
      ospackages.each do |package|
        @os_packages.push(package[:package])
      end
    end
  end

  def read_lang_fw_values
    log_build_output('Read Framework Settings')
    @framework = @blueprint[:software][:framework]
    @runtime = @blueprint[:software][:language]
    @memory = @blueprint[:software][:required_memory]
  end

  def read_pkg_modules
    @apache_modules = []
    @pear_modules = []
    @php_modules = []
    @pecl_modules = []
    @npm_modules = []
    @lua_modules = []

    pkg_modules = @blueprint[:software][:modules]
    if pkg_modules.is_a?(Array)  # not an error just nada
      pkg_modules.each do |pkg_module|
        os_package = pkg_module[:os_package]
        if os_package.nil? == false && os_package != ''
          @os_packages.push(os_package)
        end
        pkg_module_type = pkg_module[:module_type]
        if pkg_module_type.nil?
          raise EngineBuilderException.new(error_hash('pkg Module missing module_type', pkg_module))
        end
        modname = pkg_module[:module_name]
        if pkg_module_type == 'pear'
          @pear_modules.push(modname)
        elsif pkg_module_type == 'pecl'
          @pecl_modules.push(modname)
        elsif pkg_module_type == 'php'
          @php_modules.push(modname)
        elsif pkg_module_type == 'apache'
          @apache_modules.push(modname)
        elsif pkg_module_type == 'npm'
          @npm_modules.push(modname)
        elsif pkg_module_type == 'lua'
          @lua_modules.push(modname)
        else
          raise EngineBuilderException.new(error_hash('pkg module_type ' + pkg_module_type + ' Unknown for ' + modname))
        end
      end
    end
  end

  def read_app_packages
    log_build_output('Read App Packages ')
    @archives_details = []
    log_build_output('Configuring install Environment')
    archives = @blueprint[:software][:installed_packages]
    if archives.is_a?(Array) # not an error just nada
      archives.each do |archive|
        archive_details = {}
        arc_src = clean_path(archive[:source_url])
        arc_name = clean_path(archive[:name])
        arc_loc = clean_path(archive[:destination])
        arc_extract = clean_path(archive[:extraction_command])
        arc_dir = clean_path(archive[:path_to_extracted])
        archive_details[:source_url] = arc_src
        archive_details[:package_name] = arc_name
        archive_details[:extraction_command] = arc_extract
        archive_details[:destination] = arc_loc
        archive_details[:path_to_extracted] = arc_dir
        archive_details[:download_type] = clean_path(archive[:download_type])
        archive_details[:command_options] = clean_path(archive[:command_options])
        @archives_details.push(archive_details)
      end
    end
  end

  def add_capability(capability)
    @capabilities = [] if @capabilities.nil?
    @capabilities.push(capability)
  end

  def read_write_permissions_recursive
    log_build_output('Read Recursive Write Permissions')
    @recursive_chmods = []
    log_build_output('set permissions recussive')
    chmods = @blueprint[:software][:file_write_permissions]
    if chmods.is_a?(Array) # not an error just nada
      chmods.each do |chmod|
        if chmod[:recursive] == true
          directory = clean_path(chmod[:path])
          @recursive_chmods.push(directory)
        end
        # FIXME: need to strip any ../ and any preceeding ./ in clean_path
      end
    end
  end

  def read_write_permissions_single
    log_build_output('Read Non-Recursive Write Permissions')
    @single_chmods = []
    log_build_output('set permissions  single')
    chmods = @blueprint[:software][:file_write_permissions]
    if chmods.is_a?(Array) # not an error just nada
      chmods.each do |chmod|
        if !chmod.key(:recursive) || chmod[:recursive] == false
          directory = clean_path(chmod[:path])
          @single_chmods.push(directory)
        end
      end
    end
  end

  def read_worker_commands
    log_build_output('Read Workers')
    @worker_commands = []
    if @blueprint[:software].key?(:workers)
      if @blueprint[:software][:workers].key?(:blocking)
        @blocking_worker = @blueprint[:software][:workers][:blocking]
      elsif @blueprint[:software][:workers].key?(:commands) # not an error just nada

        @blueprint[:software][:workers][:commands].each do |worker|
          #      if worker[:name] = @blueprint[:software][:blocking_worker_name]
          #        @blocking_worker = worker[:command]
          #      else
          @worker_commands.push(worker[:command])
          #   end
        end
      end
    end
  end

  def read_sed_strings
    log_build_output('Read Sed Strings')
    @sed_strings = {}
    @sed_strings[:src_file] = []
    @sed_strings[:dest_file] = []
    @sed_strings[:sed_str] = []
    @sed_strings[:tmp_file] = []
    log_build_output('set sed strings')
    seds = @blueprint[:software][:replacement_strings]
    if seds.is_a?(Array) # not an error just nada
      n = 0
      seds.each do |sed|
        file = clean_path(sed[:file])
        dest = clean_path(sed[:destination])
        tmp_file = '/tmp/' + File.basename(file) + '.' + n.to_s
        if file.match(/^_TEMPLATES.*/).nil? == false
          template_file = file.gsub(/^_TEMPLATES/, '')
        else
          template_file = nil
        end
        if template_file.nil? == false
          src_file = '/home/engines/templates/' + template_file
        else
          src_file = '/home/app/' + file
        end
        dest_file = '/home/app/' + dest
        sedstr = sed[:replacement_string]
        @sed_strings[:src_file].push(src_file)
        @sed_strings[:dest_file].push(dest_file)
        @sed_strings[:tmp_file].push(tmp_file)
        @sed_strings[:sed_str].push(sedstr)
        n += 1
      end
    end
  end

  def read_mapped_ports
    @mapped_ports = {}
    log_build_output('Read Work Ports')
    ports = @blueprint[:software][:ports]
    if ports.is_a?(Array) # not an error just nada
      ports.each do |port|
        portnum = port[:port]
        if port.key?(:name)
          name = port[:name]
        else
          name = port[:port].to_s
        end

        external = port[:external]
        type = port[:protocol]
        type = 'tcp' if type.is_a?(String) == false || type.size == 0
        type = 'both' if type == 'TCP and UDP'
        type.downcase!
        # FIXME: when public ports supported
        SystemDebug.debug(SystemDebug.builder, 'Port ' + name + ':' + portnum.to_s + ':' + external.to_s + '/' + type)
        # @mapped_ports.push(WorkPort.work_port_hash(name, portnum, external, false, type))
        @mapped_ports[name] = WorkPort.work_port_hash(name, portnum, external, true, type)
      end
    end
  end

  def blueprint_env_varaibles
    @blueprint[:software][:variables]
  end

  def read_environment_variables
    log_build_output('Read Environment Variables')
    @environments = []
    envs = blueprint_env_varaibles
    if envs.is_a?(Array) # not an error just nada
      envs.each do |env|
        name = env[:name]
        log_build_output('Process Env Variable ' + name )
        value = env[:value]
        ask = env[:ask_at_build_time]
        mandatory = env[:mandatory]
        build_time_only = env[:build_time_only]
        label = env[:label]
        immutable = env[:immutable]
        # lookup_system_values = env[:lookup_system_values]

        unless @builder.set_environments.nil?
          log_build_output('Merging supplied Environment Variable:' + name.to_s)
          SystemDebug.debug(SystemDebug.builder, :looking_for_, name)
          SystemDebug.debug(SystemDebug.builder, 'from ' ,@builder.set_environments)
          if ask && @builder.set_environments.key?(name.to_sym)
            entered_value = @builder.set_environments[name.to_sym]
            if entered_value.nil? == false && entered_value.length != 0 # FIXME: needs to be removed
              value = entered_value
              SystemDebug.debug(SystemDebug.builder, :value_set, value)
            end
            log_build_output('Merged supplied Environment Variable:' + name.to_s)
          else
            log_build_output('No supplied Environment Variables')
          end

        end
        name.gsub!(/ /, '_')
        ev = EnvironmentVariable.new(name, value, ask, mandatory, build_time_only, label, immutable)
        @environments.push(ev)
      end
    end
  end

  def read_actionators
    log_build_output('Read Actionators')
    SystemDebug.debug(SystemDebug.builder, ' readin in actionators', @blueprint[:software][:actionators])
    #  STDERR.puts(' readin in actionators', @blueprint[:software][:actionators].to_s)
    if @blueprint[:software].key?(:actionators)
      @actionators = {}
      @blueprint[:software][:actionators].each do |actionator |
        @actionators[actionator[:name]] = actionator
      end
      #     STDERR.puts('Red actionators', @blueprint[:software][:actionators].to_s)
      SystemDebug.debug(SystemDebug.builder, @actionators)
    else
      SystemDebug.debug(SystemDebug.builder, 'No actionators')
      @actionators = nil
    end
  end

end