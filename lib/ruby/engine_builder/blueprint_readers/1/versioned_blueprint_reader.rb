require_relative '../blueprint_reader.rb'

class VersionedBlueprintReader < BluePrintReader
  @schema = 1
  attr_reader   :first_run_url,
  :continuous_deployment,
  :schedules ,
  :external_repositories
  def read_scripts
    return unless @blueprint[:software].key?(:scripts)
    @custom_start_script = @blueprint[:software][:scripts][:start][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:start) &&  @blueprint[:software][:scripts][:start].key?(:content)
    @custom_stop_script = @blueprint[:software][:scripts][:shutdown][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:shutdown) &&  @blueprint[:software][:scripts][:shutdown].key?(:content)
    @custom_install_script = @blueprint[:software][:scripts][:install][:content].gsub(/\r/, '') if @blueprint[:software][:scripts].key?(:install) &&  @blueprint[:software][:scripts][:install].key?(:content)
    @custom_post_install_script = @blueprint[:software][:scripts][:post_install][:content].gsub(/\r/, '') if  @blueprint[:software][:scripts].key?(:post_install) &&  @blueprint[:software][:scripts][:post_install].key?(:content)
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
      file = clean_path(sed[:source_file])
      dest = clean_path(sed[:destination_file])
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
      sedstr = sed[:string]
      @sed_strings[:src_file].push(src_file)
      @sed_strings[:dest_file].push(dest_file)
      @sed_strings[:tmp_file].push(tmp_file)
      @sed_strings[:sed_str].push(sedstr)
      n += 1
    end

  end

  def read_web_port_overide
    if @blueprint[:software][:base].key?(:framework_port_overide) == true
      @web_port = @blueprint[:software][:base][:framework_port_overide]
      @web_port = nil if @web_port == 0
    end
  end

  def read_lang_fw_values
    log_build_output('Read Framework Settings')
    @framework = @blueprint[:software][:base][:framework]
    @runtime = @blueprint[:software][:base][:framework] # Fix me load langauge from framwork file [:language]
    @memory = @blueprint[:software][:base][:required_memory]
  end

  def read_install_report_template
    @install_report_template = @blueprint[:software][:base][:installation_report]
  end

  def read_deployment_type
    @deployment_type = @blueprint[:software][:base][:deployment_type]
  end

  def continuous_deployment
    @continuous_deployment = @blueprint[:software][:base][:continuous_deployment]
  end

  def first_run_url
    @first_run_url = @blueprint[:software][:base][:first_run_url]
  end

  def read_web_root
    @web_root = @blueprint[:software][:base][:web_root_directory] if @blueprint[:software][:base].key?(:web_root_directory)
    SystemDebug.debug(SystemDebug.builder, ' @web_root ', @web_root)
  end

  def blueprint_env_varaibles
    @blueprint[:software][:environment_variables]
  end

  def read_sql_seed
    return true unless @blueprint[:software].key?(:database_seed_file) && @blueprint[:software][:database_seed_file][:content].nil? == false
    database_seed_file = @blueprint[:software][:database_seed_file][:content]
    @database_seed = database_seed_file unless database_seed_file.nil?
  end

  def read_pkg_modules
    @apache_modules = []
    @pear_modules = []
    @php_modules = []
    @pecl_modules = []
    @npm_modules = []
    @lua_modules = []

    pkg_modules = @blueprint[:software][:required_modules]
    return true unless pkg_modules.is_a?(Array)  # not an error just nada
    pkg_modules.each do |pkg_module|
      os_package = pkg_module[:os_package]
      if os_package.nil? == false && os_package != ''
        @os_packages.push(os_package)
      end
      pkg_module_type = pkg_module[:type]
      if pkg_module_type.nil? == true
        raise EngineBuilderException.new(error_hash('pkg Module missing type'))
      end

      modname = pkg_module[:name]
      SystemDebug.debug(SystemDebug.builder, ' modules  modname',  modname)
      pkg_module_type.downcase!
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
    true
  end

  def read_actionators
    log_build_output('Read Actionators')
    SystemDebug.debug(SystemDebug.builder,' readin in actionators', @blueprint[:software][:actionators])
    #   STDERR.puts(' readin in actionators', @blueprint[:software][:actionators].to_s)
    if @blueprint[:software].key?(:actionators)
      @actionators = {}
      @blueprint[:software][:actionators].each do |actionator |
        @actionators[actionator[:name]] = actionator
      end
      #   STDERR.puts('Red actionators', @blueprint[:software][:actionators].to_s)
      SystemDebug.debug(SystemDebug.builder, @actionators)
    else
      SystemDebug.debug(SystemDebug.builder, 'No actionators')
      @actionators = nil
    end
  end

  def read_schedules
    return true if @blueprint[:software][:schedules].nil?
    @schedules = @blueprint[:software][:schedules]
  end

  def read_repos
    @external_repositories = @blueprint[:software][:external_repositories] if @blueprint[:software].key?(:external_repositories)
  end

  def process_blueprint
    super
    read_schedules
    read_repos
  end

  def read_apache_htaccess_files
    if @blueprint[:software].key?(:framework_specific)
      @apache_htaccess_files = @blueprint[:software][:framework_specific][:apache_htaccess_files] if @blueprint[:software][:framework_specific][:apache_htaccess_files].is_a?(Array)
        STDERR.puts(' htaccess ' + @apache_htaccess_files.to_s)
    end
  end

  def read_custom_php_inis
    if @blueprint[:software].key?(:framework_specific)
      @custom_php_inis = @blueprint[:software][:framework_specific][:custom_php_inis] if @blueprint[:software][:framework_specific][:custom_php_inis].is_a?(Array)
      STDERR.puts(' custom_php_inis ' + @custom_php_inis.to_s)
    end
  end

  def read_apache_httpd_configurations
    if @blueprint[:software].key?(:framework_specific)
      @apache_httpd_configurations = @blueprint[:software][:framework_specific][:apache_httpd_configurations] if @blueprint[:software][:framework_specific][:apache_httpd_configurations].is_a?(Array)
      STDERR.puts(' apache_httpd_configurations ' + @apache_httpd_configurations.to_s)
    end
  end
end