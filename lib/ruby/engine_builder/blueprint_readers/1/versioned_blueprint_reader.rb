require_relative '../blueprint_reader.rb'

class VersionedBlueprintReader < BluePrintReader
  @schema = 1
  attr_reader :continuous_deployment,
  :schedules ,
  :external_repositories,
  :sudo_list
  
  def read_scripts
    if @blueprint[:software].key?(:scripts)
      @custom_start_script = @blueprint[:software][:scripts][:start][:content].gsub(/\r/, '') \
      if @blueprint[:software][:scripts].key?(:start) \
      && @blueprint[:software][:scripts][:start].key?(:content) \
      && @blueprint[:software][:scripts][:start][:content].length > 1
        
      @custom_stop_script = @blueprint[:software][:scripts][:shutdown][:content].gsub(/\r/, '') \
      if @blueprint[:software][:scripts].key?(:shutdown) \
      &&  @blueprint[:software][:scripts][:shutdown].key?(:content) \
      &&  @blueprint[:software][:scripts][:shutdown][:content].length > 1
           
      @custom_install_script = @blueprint[:software][:scripts][:install][:content].gsub(/\r/, '') \
      if @blueprint[:software][:scripts].key?(:install) \
      && @blueprint[:software][:scripts][:install].key?(:content)\
      &&  @blueprint[:software][:scripts][:install][:content].length > 1
        
      @custom_post_install_script = @blueprint[:software][:scripts][:post_install][:content].gsub(/\r/, '') \
      if  @blueprint[:software][:scripts].key?(:post_install) \
      && @blueprint[:software][:scripts][:post_install].key?(:content) \
      && @blueprint[:software][:scripts][:post_install][:content].length > 1
        @custom_first_run_script = @blueprint[:software][:scripts][:first_run][:content].gsub(/\r/, '') \
        if @blueprint[:software][:scripts].key?(:first_run) \
        && @blueprint[:software][:scripts][:first_run].key?(:content) \
        && @blueprint[:software][:scripts][:first_run][:content].length > 1
      
    end
  end
 
  def read_sed_strings
    log_build_output('Read Sed Strings')
    @sed_strings = {
      src_file: [],
      dest_file: [],
      sed_str: [],
      tmp_file: []
    }

    log_build_output('set sed strings')
    seds = @blueprint[:software][:replacement_strings]
    if seds.is_a?(Array) # not an error just nada
      n = 0
      seds.each do |sed|
        src_file = clean_path(sed[:source_file])
        dest_file = clean_path(sed[:destination_file])
        tmp_file = "/tmp/#{File.basename(src_file)}.#{n}"
        if src_file.match(/^_TEMPLATES.*/).nil? == false
          template_file = src_file.gsub(/^_TEMPLATES/, '')
        else
          template_file = nil
        end
        if template_file.nil? == false
          src_file = "/home/engines/templates/#{template_file}"
        else
          src_file = "/home/app/#{src_file}" unless src_file.start_with?('/home/app/')
        end
        dest_file = "/home/app/#{dest_file}" unless dest_file.start_with?('/home/app/')
        sedstr = sed[:string]
        @sed_strings[:src_file].push(src_file)
        @sed_strings[:dest_file].push(dest_file)
        @sed_strings[:tmp_file].push(tmp_file)
        @sed_strings[:sed_str].push(sedstr)
        n += 1
      end
    end
  end

  def read_web_port_overide
    if @blueprint[:software][:base].key?(:framework_port_override)
      @web_port = @blueprint[:software][:base][:framework_port_override]
      @web_port = nil if @web_port == 0
    end
  end

  def read_lang_fw_values
    @framework = @blueprint[:software][:base][:framework]
    @runtime = @blueprint[:software][:base][:framework] # Fix me load langauge from framwork file [:language]
    @memory = @blueprint[:software][:base][:required_memory]
    if @framework ==  'docker'
      @base_image = @blueprint[:software][:base][:parent_image]
      @cont_user = @blueprint[:software][:base][:run_as_user]
    end
    log_build_output('Read Framework Settings ' + @framework.to_s + ' with ' +  @memory.to_s + 'MB' )
  end

  def read_install_report_template
    @install_report_template = @blueprint[:software][:base][:installation_report]
  end

  def read_deployment_type
    @deployment_type = @blueprint[:software][:base][:deployment_type]
  end

  def continuous_deployment
    @continuous_deployment = true if @blueprint[:software][:base][:continuous_deployment] == 'true'
  end

  def first_run_url
    @first_run_url = @blueprint[:software][:base][:first_run_url]
  end

  def read_web_root
    @web_root = @blueprint[:software][:base][:web_root_directory] if @blueprint[:software][:base].key?(:web_root_directory)
  #  SystemDebug.debug(SystemDebug.builder, ' @web_root ', @web_root)
  end

  def blueprint_env_varaibles
    @blueprint[:software][:environment_variables]
  end
  
  def sudoer_list
  unless @blueprint[:software][:base][:sudo_list].nil?
     @sudo_list =  @blueprint[:software][:base][:sudo_list].split(/[ \r\n,;]/)  
  else
    @sudo_list = nil
  end
  end
 

  def read_sql_seed
    if @blueprint[:software].key?(:database_seed_file) && @blueprint[:software][:database_seed_file][:content].nil? == false
      database_seed_file = @blueprint[:software][:database_seed_file][:content]
      @database_seed = database_seed_file unless database_seed_file.nil?
    end
  end

  def read_pkg_modules
    @apache_modules = []
    @pear_modules = []
    @php_modules = []
    @pecl_modules = []
    @npm_modules = []
    @lua_modules = []
    @python_modules = []  
    

    pkg_modules = @blueprint[:software][:required_modules]
    if pkg_modules.is_a?(Array)  # not an error just nada
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
#        SystemDebug.debug(SystemDebug.builder, ' modules  modname',  modname)
        pkg_module_type.downcase!
        if pkg_module_type == 'pear'
          @pear_modules.push(modname)
        elsif pkg_module_type == 'pecl'
          @pecl_modules.push(modname)
        elsif pkg_module_type == 'php'
          @php_modules.push(modname)
        elsif pkg_module_type == 'python'
          @python_modules.push(modname)
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

  def read_actionators
    log_build_output('Read Actionators')
 #   SystemDebug.debug(SystemDebug.builder,' readin in actionators', @blueprint[:software][:actionators])
    #   STDERR.puts(' readin in actionators', @blueprint[:software][:actionators].to_s)
    if @blueprint[:software].key?(:actionators)
      @actionators = {}
      @blueprint[:software][:actionators].each do |actionator |
        @actionators[actionator[:name]] = actionator
      end
      #   STDERR.puts('Red actionators', @blueprint[:software][:actionators].to_s)
 #     SystemDebug.debug(SystemDebug.builder, @actionators)
    else
#      SystemDebug.debug(SystemDebug.builder, 'No actionators')
      @actionators = nil
    end
  end

  def read_schedules
    @schedules = @blueprint[:software][:schedules] unless @blueprint[:software][:schedules].nil?

  end

  def read_repos
    @external_repositories = @blueprint[:software][:external_repositories] if @blueprint[:software].key?(:external_repositories)
  end

  def process_blueprint
    super
    read_schedules
    read_repos
    sudoer_list
  end

  def read_apache_htaccess_files
    if @blueprint[:software].key?(:framework_specific)
      @apache_htaccess_files = @blueprint[:software][:framework_specific][:apache_htaccess_files] if @blueprint[:software][:framework_specific][:apache_htaccess_files].is_a?(Array)
    end
  end

  def read_custom_php_inis
    if @blueprint[:software].key?(:framework_specific)
      @custom_php_inis = @blueprint[:software][:framework_specific][:custom_php_inis] if @blueprint[:software][:framework_specific][:custom_php_inis].is_a?(Array)
    end
  end

  def read_apache_httpd_configurations
    if @blueprint[:software].key?(:framework_specific)
      @apache_httpd_configurations = @blueprint[:software][:framework_specific][:apache_httpd_configurations] if @blueprint[:software][:framework_specific][:apache_httpd_configurations].is_a?(Array)
    end
  end
end