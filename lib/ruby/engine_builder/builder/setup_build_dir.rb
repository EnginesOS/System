class EngineBuilder < ErrorsApi

  require_relative 'config_file_writer.rb'
  require_relative 'docker_file_builder/docker_file_builder.rb'
  def backup_lastbuild
    dir = basedir
    backup = "#{dir}.backup"
    FileUtils.rm_rf(backup) if Dir.exist?(backup)
    FileUtils.mv(dir, backup) if Dir.exist?(dir)
    true
  end

  def setup_build_dir
    setup_default_files
    ConfigFileWriter.compile_base_docker_files(templater, basedir)
    unless @blueprint_reader.web_port.nil?
      @web_port = @blueprint_reader.web_port
    else
      read_web_port
    end
    read_framework_user
    init_container_info_dir
    save_params
    @build_params[:mapped_ports] = @blueprint_reader.mapped_ports
    #  SystemDebug.debug(SystemDebug.builder, :ports, @build_params[:mapped_ports])
    #  SystemDebug.debug(SystemDebug.builder, :attached_services, @build_params[:attached_services])
    unless   @build_params[:reinstall] == true
      service_builder.required_services_are_running?
      service_builder.create_persistent_services(@blueprint_reader.services, @blueprint_reader.environments, @build_params[:attached_services])
    end
    #   SystemDebug.debug(SystemDebug.builder, 'Services Attached')
    apply_templates_to_environments
    #  SystemDebug.debug(SystemDebug.builder, 'Templates Applied')
    create_engines_config_files
    #    SystemDebug.debug(SystemDebug.builder, 'Configs written')
    index = 0
    unless @blueprint_reader.sed_strings.nil? || @blueprint_reader.sed_strings[:sed_str].nil?
      @blueprint_reader.sed_strings[:sed_str].each do |sed_string|
        sed_string = templater.process_templated_string(sed_string)
        @blueprint_reader.sed_strings[:sed_str][index] = sed_string
        index += 1
      end
    end
    @build_params[:app_is_persistent] = service_builder.app_is_persistent
    dockerfile_builder = DockerFileBuilder.new(@blueprint_reader, @build_params, @web_port, self)
    dockerfile_builder.write_files_for_docker
    #  SystemDebug.debug(SystemDebug.builder, 'Docker file  written')
    write_env_file
    #  SystemDebug.debug(SystemDebug.builder, 'Eviron file  written')
    setup_framework_logging
    #   SystemDebug.debug(SystemDebug.builder, 'Logging setup')
    write_persistent_vol_maps
  end

  def write_software_file(filename, content)
    ConfigFileWriter.write_templated_file(templater, "#{basedir}/#{filename}", content)
    log_build_output("Wrote #{basedir}/#{filename}")
  end

  private

  def write_persistent_vol_maps
    persistent_dirs =  @blueprint_reader.persistent_dirs
    unless persistent_dirs.nil?
      content = ''
      persistent_dirs.each do |persistent|
        content += persistent[:path].to_s + ' ' + persistent[:volume_name].to_s + "\n"
      end
      write_software_file('/home/fs/vol_dir_maps', content)
    end
    persistent_files = @blueprint_reader.persistent_files
    unless persistent_files.nil?
      content = ''
      persistent_files.each do |persistent|
        persistent[:volume_name] = service_builder.default_vol if persistent[:volume_name].nil?
        #    STDERR.puts('persistent[:path]:' +  persistent[:path].to_s + ' persistent[:volume_name]:' + persistent[:volume_name].to_s  + "\n")
        content += persistent[:path] + ' ' + persistent[:volume_name] + "\n"
      end
      write_software_file('/home/fs/vol_file_maps', content)
    end
  end

  def create_build_dir
    FileUtils.mkdir_p(basedir)
  end

  def create_engines_config_files
    create_template_files
    create_php_ini
    create_httaccess
    create_apache_config
    create_scripts
    ConfigFileWriter.create_sudoers_file(@blueprint_reader.sudo_list, @web_user, basedir)
  end

  def create_template_files
    if @blueprint_reader.template_files
      @blueprint_reader.template_files.each do |template_hash|
        template_hash[:path].sub!(/^\/home/,'')
        template_hash[:path] = templater.process_templated_string(template_hash[:path].sub(/^\/home/,''))
        log_build_output('creating app template file:' + template_hash[:path].to_s)
        write_software_file('/home/engines/templates/' + template_hash[:path], template_hash[:content])
      end
    end
  end

  def create_httaccess
    if @blueprint_reader.apache_htaccess_files
      @blueprint_reader.apache_htaccess_files.each do |htaccess_hash|
        write_software_file(SystemConfig.htaccessSourceDir + htaccess_hash[:directory] + '/.htaccess', htaccess_hash[:content])
      end
    end
  end

  def create_php_ini
    FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomPHPiniFile))
    if @blueprint_reader.custom_php_inis
      contents = ''
      @blueprint_reader.custom_php_inis.each do |php_ini_hash|
        content = php_ini_hash[:content].gsub(/\r/, '')
        contents = contents + "\n" + content
      end
      write_software_file(SystemConfig.CustomPHPiniFile, contents)
    end
  end

  def create_apache_config
    if @blueprint_reader.apache_httpd_configurations
      FileUtils.mkdir_p(basedir + File.dirname(SystemConfig.CustomApacheConfFile))
      contents = ''
      @blueprint_reader.apache_httpd_configurations.each do |httpd_configuration|
        contents = contents + httpd_configuration[:content] + "\n"
      end
      write_software_file(SystemConfig.CustomApacheConfFile, contents)
    end
  end

  def write_env_file
    log_build_output('Setting up Environments')
    env_file = File.new(basedir + '/home/app.env', 'a')
    begin
      env_file.puts('')
      @blueprint_reader.environments.each do |env|
        env_file.puts(env.name) unless env.build_time_only
      end
      @set_environments.each do |env|
        env_file.puts(env[0])
      end
    ensure
      env_file.close
    end
  end

  def read_framework_user
    STDERR.puts("Frame work #{@blueprint_reader.framework}")
    if @blueprint_reader.framework == 'docker'
      @web_user = @blueprint_reader.cont_user
      @cont_user_id =  @blueprint_reader.cont_user #fix me and add id
      #   STDERR.puts("Set web user to:" + @web_user.to_s)
    else
      log_build_output('Read Web User')
      stef = File.open(basedir + '/home/engines/etc/stack.env', 'r')
      begin
        while line = stef.gets do
          if line.include?('USER')
            i = line.split('=')
            @web_user = i[1].strip
          end
        end
      ensure
        stef.close
      end
    end
    #  STDERR.puts("\n" + ' web user ' + @web_user.to_s + ':' + "cont user id:" + @cont_user_id.to_s)
    @web_user
  end

  def apply_templates_to_environments
    @blueprint_reader.environments.each do |env|
      env.value = templater.process_templated_string(env.value) if env.value.is_a?(String)
    end
  end

  def read_web_port
    unless @blueprint_reader.framework == 'docker'
     begin
    log_build_output('Setting Web port')
    stef = File.open(basedir + '/home/engines/etc/stack.env', 'r')
    begin
      while line = stef.gets do
        if line.include?('PORT')
          i = line.split('=')
          @web_port = i[1].strip
          SystemDebug.debug(SystemDebug.builder, :web_port_line, line)
        end
      end
    end
    ensure
      stef.close
    end
  end
  end

  def setup_default_files
    log_build_output('Setup Default Files ')
    log_error_mesg('Failed to setup Global Defaults', self) unless setup_global_defaults
    setup_framework_defaults
  end

  def setup_global_defaults
    log_build_output('Setup global defaults')
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates  + '/global/* ' + basedir
    system(cmd)
  end

  def setup_framework_defaults
    log_build_output('Copy in default templates for Framework ' + @blueprint_reader.framework.to_s + ' basedir ' + basedir.to_s)
    cmd = 'cp -r ' + SystemConfig.DeploymentTemplates + '/' + @blueprint_reader.framework + '/* ' + basedir
    r = system(cmd)
    if @blueprint_reader.framework == 'docker'
      df = File.read(basedir + '/_Dockerfile.tmpl')
      df = 'FROM ' + @blueprint_reader.base_image + "\n" + 'ENV ContUser ' + @blueprint_reader.cont_user + "\n" + df
      fw = File.new(basedir  + '/Dockerfile.tmpl', 'w+')
      begin
        fw.write(df)
      ensure
        fw.close
      end
    end
  end

  def setup_framework_logging
    log_build_output('Setting up logging')
    rmt_log_dir_var_fname = basedir + '/home/engines/etc/LOG_DIR'
    if File.exist?(rmt_log_dir_var_fname)
      rmt_log_dir_varfile = File.open(rmt_log_dir_var_fname)
      begin
        rmt_log_dir = rmt_log_dir_varfile.read
      ensure
        rmt_log_dir_varfile.close
      end
    else
      rmt_log_dir = '/var/log'
    end
    local_log_dir = SystemConfig.SystemLogRoot + '/apps/' + @build_params[:engine_name]
    Dir.mkdir(local_log_dir) unless Dir.exist?(local_log_dir)
    ' -v ' + local_log_dir + ':' + rmt_log_dir + ':rw '
  end

  def save_params()
    p_file = File.open( basedir + '/build_params','w')
    begin
      p_file.write(@build_params.to_s)
    ensure
      p_file.close
    end
  end

  def init_container_info_dir
    ContainerStateFiles.init_container_info_dir(
    {c_type: 'app',
      c_name: @build_params[:engine_name],
      keys: {
      uid: @cont_user_id,
      frame_work: @blueprint_reader.framework
      }
    })
  end
end
