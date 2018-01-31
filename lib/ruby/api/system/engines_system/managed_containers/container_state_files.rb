module ContainerSystemStateFiles
  def build_running_service(service_name, service_type_dir, system_value_access)
    config_template_file_name = service_type_dir + service_name + '/config.yaml'
    unless File.exist?(config_template_file_name)
      SystemUtils.log_error_mesg('Running exist', service_name)
    else
      config_template = File.read(config_template_file_name)
      templator = Templater.new(system_value_access, nil)
      running_config = templator.process_templated_string(config_template)
      yam1_file_name = service_type_dir + service_name + '/running.yaml'
      yaml_file = File.new(yam1_file_name, 'w+')
      yaml_file.write(running_config)
      yaml_file.close
      true
    end
  end

  def schedules_dir(c)
    container_state_dir(c) + '/schedules/'
  end

  def schedules_file(c)
    schedules_dir(c) + '/schedules.yaml'
  end

  def actionator_dir(c)
    container_state_dir(c) + '/actionators/'
  end

  def container_flag_dir(c)
    container_state_dir(c) + '/run/flags/'
  end

  def restart_flag_file(c)
    container_flag_dir(c) + 'restart_required'
  end

  def rebuild_flag_file(c)
    container_flag_dir(c) + 'rebuild_required'
  end

  def read_container_id(c)
    cidfile = container_cid_file(c)
    if File.exist?(cidfile)
      r = File.read(cidfile)
      r.gsub!(/\s+/, '').strip
    else
      -1
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
    '-1'
  end

  def create_container_dirs(c)
    state_dir = container_state_dir(c)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      Dir.mkdir(state_dir + '/run') unless Dir.exist?(state_dir + '/run')
      Dir.mkdir(state_dir + '/run/flags') unless Dir.exist?(state_dir + '/run/flags')
      FileUtils.chown_R(nil, 'containers', state_dir + '/run')
      FileUtils.chmod_R('u+r', state_dir + '/run')
      FileUtils.chmod_R('g+w', state_dir + '/run')
    end
    log_dir = container_log_dir(c)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    if c.is_service?
      Dir.mkdir(state_dir + '/configurations/') unless File.directory?(state_dir + '/configurations')
      Dir.mkdir(state_dir + '/configurations/default') unless File.directory?(state_dir + '/configurations/default')
    end

    key_dir =  key_dir(c)
    unless Dir.exist?(key_dir)
      Dir.mkdir(key_dir)  unless File.directory?(key_dir)
      FileUtils.chown(nil, 'containers', key_dir)
      FileUtils.chmod('g+w', key_dir)
    end
    #  STDERR.puts(' key dir 1 ' + key_dir.to_s)
    true
  end

  def container_info_tree_dir(c)
    SystemConfig.InfoTreeDir  + '/' + c.ctype + 's/' + c.container_name
  end
  
  def key_dir(c)
    SystemConfig.SSHStore + '/' + c.ctype + 's/' + c.container_name
  end

  def clear_container_var_run(c)
    File.unlink(container_state_dir(c) + '/startup_complete') if File.exist?(container_state_dir(c) + '/startup_complete')
    true
  end

  def container_cid_file(c)
    SystemConfig.CidDir + '/' + c.container_name + '.cid'
  end

  def delete_container_configs(volbuilder, c)
    cidfile = SystemConfig.CidDir + '/' + c.container_name + '.cid'
    File.delete(cidfile) if File.exist?(cidfile)
    result = volbuilder.execute_command(:remove, {target: c.container_name})
    #volbuilder.wait_for('destroy', 30)
    begin
      FileUtils.rm_rf(container_state_dir(c))
    rescue
    end
    SystemUtils.run_system('/opt/engines/system/scripts/system/clear_container_dir.sh ' + c.container_name)
    true
  end

  def destroy_container(c)
    File.delete(container_cid_file(c)) if File.exist?(container_cid_file(c))

    true # File may or may not exist
  end

  def container_log_dir(c)
    SystemConfig.SystemLogRoot + '/' + c.ctype + 's/' + c.container_name
  end

  def container_ssh_keydir(c)
    SystemConfig.SSHStore + '/' + c.ctype + 's/' + c.container_name
  end

  def clear_cid_file(c)
    cidfile = container_cid_file(c)
    File.delete(cidfile) if File.exist?(cidfile)
    true
  end

  def container_service_dir(service_name)
    SystemConfig.RunDir + '/services/' + service_name
  end

  def container_disabled_service_dir(service_name)
    SystemConfig.RunDir + '/services-disabled/' + service_name
  end

  def container_state_dir(c)
    SystemConfig.RunDir + '/' + c.ctype + 's/' + c.container_name
  end

  def save_container_log(c, options = {} )
    if c.has_container?
      unless options[:over_write] == true
        log_name = Time.now.strftime('%Y-%m-%d_%H-%M-%S') + '.log'
      else
        log_name = 'last.log'
      end
      log_file = File.new(container_log_dir(c) + '/' + log_name, 'w+')
      unless  options.key?(:max_length)
        options[:max_length] = 4096
      end
      log_file.write(
        #DockerUtils.docker_stream_as_result(
        c.logs_container(options[:max_length])
        #, {}).to_yaml
        )
      log_file.close
    end
  end
end
