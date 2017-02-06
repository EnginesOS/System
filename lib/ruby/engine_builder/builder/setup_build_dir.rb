def setup_build_dir
  return post_failed_build_clean_up unless setup_default_files
  return post_failed_build_clean_up unless ConfigFileWriter.compile_base_docker_files(@templater, basedir)
  unless @blueprint_reader.web_port.nil?
    @web_port = @blueprint_reader.web_port
  else
    read_web_port
  end
  read_web_user

  @build_params[:mapped_ports] =  @blueprint_reader.mapped_ports
  SystemDebug.debug(SystemDebug.builder,   :ports, @build_params[:mapped_ports])
  SystemDebug.debug(SystemDebug.builder,   :attached_services, @build_params[:attached_services])
  return build_failed(@service_builder.last_error) unless @service_builder.required_services_are_running?

  return build_failed(@service_builder.last_error) if @service_builder.create_persistent_services(@blueprint_reader.services, @blueprint_reader.environments,@build_params[:attached_services]).is_a?(EnginesError)

  apply_templates_to_environments
  create_engines_config_files
  index = 0
  unless @blueprint_reader.sed_strings.nil? || @blueprint_reader.sed_strings[:sed_str].nil?
    @blueprint_reader.sed_strings[:sed_str].each do |sed_string|
      sed_string = @templater.process_templated_string(sed_string)
      @blueprint_reader.sed_strings[:sed_str][index] = sed_string
      index += 1
    end
  end
  @build_params[:app_is_persistent] = @service_builder.app_is_persistent
  dockerfile_builder = DockerFileBuilder.new(@blueprint_reader, @build_params, @web_port, self)
  return post_failed_build_clean_up unless dockerfile_builder.write_files_for_docker

  write_env_file

  setup_framework_logging
  return true
end

def create_build_dir
  FileUtils.mkdir_p(basedir)
rescue StandardError => e
  log_exception(e)
end

def create_engines_config_files
  create_template_files
  create_php_ini
  create_apache_config
  create_scripts
end

def create_template_files
  if @blueprint[:software].key?(:template_files) && @blueprint[:software][:template_files].nil? == false
    @blueprint[:software][:template_files].each do |template_hash|
      template_hash[:path].sub!(/^\/home/,'')
      write_software_file('/home/engines/templates/' + template_hash[:path], template_hash[:content])
    end
  end
end

def create_httaccess
  if @blueprint[:software].key?(:apache_htaccess_files) && @blueprint[:software][:apache_htaccess_files].nil? == false
    @blueprint[:software][:apache_htaccess_files].each do |htaccess_hash|
      write_software_file('/home/engines/htaccess_files' + htaccess_hash[:directory] + '/.htaccess', htaccess_hash[:htaccess_content])
    end
  end
end

def create_php_ini
  FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomPHPiniFile))
  if @blueprint[:software].key?(:custom_php_inis) \
  && @blueprint[:software][:custom_php_inis].nil? == false \
  && @blueprint[:software][:custom_php_inis].length > 0
    contents = ''
    @blueprint[:software][:custom_php_inis].each do |php_ini_hash|
      content = php_ini_hash[:content].gsub(/\r/, '')
      contents = contents + "\n" + content
    end
    write_software_file(SystemConfig.CustomPHPiniFile, contents)
  end
end

def create_apache_config
  if @blueprint[:software].key?(:apache_httpd_configurations) \
  && @blueprint[:software][:apache_httpd_configurations].nil? == false \
  && @blueprint[:software][:apache_httpd_configurations].length > 0
    FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomApacheConfFile))
    #  @ if @blueprint[:software].key?(:apache_httpd_configurations) && @blueprint[:software][:apache_httpd_configurations]  != nil
    contents = ''
    @blueprint[:software][:apache_httpd_configurations].each do |httpd_configuration|
      contents = contents + httpd_configuration[:httpd_configuration] + "\n"

    end
    write_software_file(SystemConfig.CustomApacheConfFile, contents)
  end
end

def write_env_file
  log_build_output('Setting up Environments')
  env_file = File.new(basedir + '/home/app.env', 'a')
  env_file.puts('')
  @blueprint_reader.environments.each do |env|
    env_file.puts(env.name) unless env.build_time_only
  end
  @set_environments.each do |env|
    env_file.puts(env[0])
  end
  env_file.close
end

def write_software_file(filename, content)
  ConfigFileWriter.write_templated_file(@templater, basedir + '/' + filename, content)
end

def create_templater
  builder_public = BuilderPublic.new(self)

  @templater = Templater.new(@core_api.system_value_access, builder_public)
rescue StandardError => e
  log_exception(e)
end

def read_web_user
  log_build_output('Read Web User')
  stef = File.open(basedir + '/home/stack.env', 'r')
  while line = stef.gets do
    if line.include?('USER')
      i = line.split('=')
      @web_user = i[1].strip
    end
  end
  stef.close
rescue StandardError => e
  log_exception(e)
end

def apply_templates_to_environments
  @blueprint_reader.environments.each do |env|
    env.value = @templater.process_templated_string(env.value)
  end
end

def read_web_port
  log_build_output('Setting Web port')
  stef = File.open(basedir + '/home/stack.env', 'r')
  while line = stef.gets do
    if line.include?('PORT')
      i = line.split('=')
      @web_port = i[1].strip
      SystemDebug.debug(SystemDebug.builder,   :web_port_line, line)
    end
  end
  stef.close
rescue StandardError => e
  log_exception(e)
  #      throw BuildStandardError.new(e,'setting web port')
end

def setup_default_files
  log_build_output('Setup Default Files')
  log_error_mesg('Failed to setup Global Defaults', self) unless setup_global_defaults
  return setup_framework_defaults
end

def setup_global_defaults
  log_build_output('Setup global defaults')
  cmd = 'cp -r ' + SystemConfig.DeploymentTemplates  + '/global/* ' + basedir
  system cmd
rescue StandardError => e
  log_exception(e)
end

def setup_framework_defaults
  log_build_output('Copy in default templates')
  cmd = 'cp -r ' + SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework + '/* ' + basedir
  system cmd
  if @blueprint_reader.framework == 'docker'
    df = File.read(SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework + '/_Dockerfile.tmpl')
    df = 'FROM: ' + @blueprint_reader.base_image + "\n" + df
      fw = File.new(basedir  + '/Dockerfile.tmpl','w+')
      fw.write(df)
      fw.close
      return true      
  end
  
rescue StandardError => e
  log_exception(e)
end

def setup_framework_logging
  log_build_output('Seting up logging')
  rmt_log_dir_var_fname = basedir + '/home/LOG_DIR'
  if File.exist?(rmt_log_dir_var_fname)
    rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
    rmt_log_dir = rmt_log_dir_varfile.read
  else
    rmt_log_dir = '/var/log'
  end
  local_log_dir = SystemConfig.SystemLogRoot + '/containers/' + @build_params[:engine_name]
  Dir.mkdir(local_log_dir) unless Dir.exist?(local_log_dir)
  rmt_log_dir_varfile.close
  return ' -v ' + local_log_dir + ':' + rmt_log_dir + ':rw '
rescue StandardError => e
  log_exception(e)
end
