class BluePrintReader
  def initialize(contname, blue_print, builder)

    @builder = builder
    @container_name = contname
    @blueprint = blue_print
    @web_port = nil
    @services = []
    @os_packages = []
  end

  attr_reader :persistant_files,
              :persistant_dirs,
              :last_error,
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
              :pecl_modules,
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
              :database_seed

  def log_build_output(line)
    @builder.log_build_output(line)
  end

  def log_build_errors(line)
    @builder.log_build_errors(line)
  end

  def clean_path(path)
    # FIXME: remove preceeding ./(s) and /(s) as well as obliterate any /../ or preceeding ../ and any ' ' or ';' or '&' or '|' etc
    return path
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
    read_persistant_files
    read_persistant_dirs
    read_web_port_overide
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_deployment_type
    @deployment_type = @blueprint[:software][:deployment_type]
  end

  def re_set_service(service_cnt, service_hash)
    @services[service_cnt] = service_hash
    # services[service_cnt]=service_hash
  end

  def read_web_port_overide
    if @blueprint[:software].key?(:framework_port_overide) == true
      @web_port = @blueprint[:software][:framework_port_overide]
    end
  end

  def read_persistant_dirs
    log_build_output('Read Persistant Dirs')
    @persistant_dirs = []
    pds = @blueprint[:software][:persistent_directories]
    return true unless pds.is_a?(Array) # not an error just nada
    pds.each do |dir|
      @persistant_dirs.push(dir[:path])
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_persistant_files
    log_build_output('Read Persistant Files')
    @persistant_files = {}
    src_paths = []
    pfs = @blueprint[:software][:persistent_files]
    return true unless pfs.is_a?(Array) # not an error just nada
    pfs.each do |file|
      path = clean_path(file[:path])
      src_paths.push(path)
    end
    @persistant_files[:src_paths] = src_paths
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_rake_list
    @rake_actions = []
    log_build_output('Read Rake List')
    rake_cmds = @blueprint[:software][:rake_tasks]
    return true unless rake_cmds.is_a?(Array) # not an error just nada
    rake_cmds.each do |rake_cmd|
      @rake_actions.push(rake_cmd)
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_services
 
    log_build_output('Read Services')
    services = @blueprint[:software][:service_configurations]
    return true unless services.is_a?(Array) # not an error just nada
    services.each do |service|
      service[:publisher_namespace] = 'EnginesSystem' if service.key?(:publisher_namespace) == false || service[:publisher_namespace].nil?
      service[:service_type] = service[:type_path]
      add_service(service)
    end
  end 

  def add_service(service_hash)
    p :add_service
    p service_hash
    @builder.templater.fill_in_dynamic_vars(service_hash)
    @services.push(service_hash)   
    return true
  end


  def read_os_packages
    log_build_output('Read OS Packages')
    ospackages = @blueprint[:software][:system_packages]
    return true unless ospackages.is_a?(Array) # not an error just nada
    ospackages.each do |package|
      @os_packages.push(package[:package])
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_lang_fw_values
    log_build_output('Read Framework Settings')
    @framework = @blueprint[:software][:framework]
    p @framework
    @runtime = @blueprint[:software][:language]
    @memory = @blueprint[:software][:required_memory]
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_pkg_modules
    @apache_modules = []
    @pear_modules = []
    @php_modules = []
    @pecl_modules = []

    pkg_modules = @blueprint[:software][:modules]
    return true unless pkg_modules.is_a?(Array)  # not an error just nada
    pkg_modules.each do |pkg_module|
      os_package = pkg_module[:os_package]
      if os_package.nil? == false && os_package != ''
        @os_packages.push(os_package)
      end
      pkg_module_type = pkg_module[:module_type]
      if pkg_module_type.nil? == true
        @last_error = 'pkg Module missing module_type'
        return false
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
      else
        @last_error = 'pkg module_type ' + pkg_module_type + ' Unknown for ' + modname
        return false
      end
    end
    return true
  end

  def read_sql_seed
    database_seed_file = @blueprint[:software][:database_seed_file]
    @database_seed = database_seed_file unless database_seed_file.nil?
  end

  def read_app_packages
    log_build_output('Read App Packages ')
    @archives_details = []
    log_build_output('Configuring install Environment')
    archives = @blueprint[:software][:installed_packages]
    return true unless archives.is_a?(Array) # not an error just nada
    archives.each do |archive|
      archive_details = {}
      arc_src = clean_path(archive[:source_url])
      arc_name = clean_path(archive[:name])
      arc_loc = clean_path(archive[:destination])
      arc_extract = clean_path(archive[:extraction_command])
      arc_dir = clean_path(archive[:path_to_extracted])
      if arc_loc == './'
        arc_loc = ''
      elsif arc_loc.end_with?('/')
        arc_loc = arc_loc.chop # note not String#chop
      end
      archive_details[:source_url] = arc_src
      archive_details[:package_name] = arc_name
      archive_details[:extraction_command] = arc_extract
      archive_details[:destination] = arc_loc
      archive_details[:path_to_extracted] = arc_dir
      p :read_in_arc_details
      p archive_details
      @archives_details.push(archive_details)
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_write_permissions_recursive
    log_build_output('Read Recursive Write Permissions')
    @recursive_chmods = []
    log_build_output('set permissions recussive')
    chmods = @blueprint[:software][:file_write_permissions]
    p :Single_Chmods
    return true unless chmods.is_a?(Array) # not an error just nada
    chmods.each do |chmod|
      p chmod
      if chmod[:recursive] == true
        directory = clean_path(chmod[:path])
        p directory
        @recursive_chmods.push(directory)
      end
      # FIXME: need to strip any ../ and any preceeding ./ in clean_path
    end
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_write_permissions_single
    log_build_output('Read Non-Recursive Write Permissions')
    @single_chmods = []
    log_build_output('set permissions  single')
    chmods = @blueprint[:software][:file_write_permissions]
    p :Recursive_Chmods
    return true unless chmods.is_a?(Array) # not an error just nada
    chmods.each do |chmod|
      p chmod
      if chmod[:recursive] == false
        p chmod[:path]
        directory = clean_path(chmod[:path])
        @single_chmods.push(directory)
      end
    end
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_worker_commands
    log_build_output('Read Workers')
    @worker_commands = []
    workers = @blueprint[:software][:workers]
    return true unless workers.is_a?(Array) # not an error just nada

    workers.each do |worker|
      @worker_commands.push(worker[:command])
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
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
    return true unless seds.is_a?(Array) # not an error just nada
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
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_mapped_ports
    @mapped_ports = []
    log_build_output('Read Work Ports')
    ports = @blueprint[:software][:ports]
    puts('Ports Json' + ports.to_s)
    return true unless ports.is_a?(Array) # not an error just nada
    ports.each do |port|
      portnum = port[:port]
      name = port[:name]
      external = port[:external]
      type = port[:protocol]
      type = 'tcp' if type.is_a?(String) == false || type.size == 0
      # FIXME: when public ports supported
      puts 'Port ' + portnum.to_s + ':' + external.to_s
      @mapped_ports.push(WorkPort.new(name, portnum, external, false, type))
    end
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def read_environment_variables
    log_build_output('Read Environment Variables')
    @environments = []
    p :set_environment_variables
    p @builder.set_environments
    envs = @blueprint[:software][:variables]
    return true unless envs.is_a?(Array) # not an error just nada
    envs.each do |env|
      p env
      name = env[:name]
      value = env[:value]
      ask = env[:ask_at_build_time]
      mandatory = env[:mandatory]
      build_time_only = env[:build_time_only]
      label = env[:label]
      immutable = env[:immutable]
      # lookup_system_values = env[:lookup_system_values]
      if @builder.set_environments.nil? == false
        p :looking_for_
        p name
        if ask && @builder.set_environments.key?(name)
          entered_value = @builder.set_environments[name]
          if entered_value.nil? == false && entered_value.length != 0 # FIXME: needs to be removed
            value = entered_value
          end
        end
      end
      name.sub!(/ /, '_')
      p :name_and_value
      p name
      p value
      ev = EnvironmentVariable.new(name, value, ask, mandatory, build_time_only, label, immutable)
      p ev
      @environments.push(ev)
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
end
