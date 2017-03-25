module ContainerStateFiles
  require_relative 'system_config.rb'

  
  def build_running_service(service_name, service_type_dir,system_value_access)
    config_template_file_name = service_type_dir + service_name + '/config.yaml'
    return SystemUtils.log_error_mesg('Running exist', service_name) unless File.exist?(config_template_file_name)
    config_template = File.read(config_template_file_name)
    templator = Templater.new(system_value_access, nil)
    running_config = templator.process_templated_string(config_template)
    yam1_file_name = service_type_dir + service_name + '/running.yaml'
    yaml_file = File.new(yam1_file_name, 'w+')
    yaml_file.write(running_config)
    yaml_file.close
    true
  end

  def schedules_dir(container)
    return container_state_dir(container) + '/schedules/'
  end

  def schedules_file(container)
     schedules_dir(container) + '/schedules.yaml'
  end

  def actionator_dir(container)
     container_state_dir(container) + '/actionators/'
  end

  def container_flag_dir(container)
     container_state_dir(container) + '/run/flags/'
  end

  def restart_flag_file(container)
     container_flag_dir(container) + 'restart_required'
  end

  def rebuild_flag_file(container)
     container_flag_dir(container) + 'rebuild_required'
  end

  def read_container_id(container)
    cidfile = container_cid_file(container)
    return -1 unless  File.exist?(cidfile)
    r = File.read(cidfile)
    r.gsub!(/\s+/, '').strip
  rescue StandardError => e
    SystemUtils.log_exception(e)
    '-1'
  end

  def create_container_dirs(container)
    state_dir = container_state_dir(container)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      Dir.mkdir(state_dir + '/run') unless Dir.exist?(state_dir + '/run')
      Dir.mkdir(state_dir + '/run/flags') unless Dir.exist?(state_dir + '/run/flags')
      FileUtils.chown_R(nil, 'containers', state_dir + '/run')
      FileUtils.chmod_R('u+r', state_dir + '/run')
      FileUtils.chmod_R('g+w', state_dir + '/run')
    end
    log_dir = container_log_dir(container)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    if container.is_service?
      Dir.mkdir(state_dir + '/configurations/') unless File.directory?(state_dir + '/configurations')
      Dir.mkdir(state_dir + '/configurations/default') unless File.directory?(state_dir + '/configurations/default')
    end

    key_dir =  key_dir(container)
    unless Dir.exist?(key_dir)
      Dir.mkdir(key_dir)  unless File.directory?(key_dir)
      FileUtils.chown(nil, 'containers',key_dir)
      FileUtils.chmod('g+w', key_dir)
    end
    true
  end

  def key_dir(container)
    SystemConfig.SSHStore + '/' + container.ctype + 's/'  + container.container_name
  end

  def clear_container_var_run(container)
    File.unlink(container_state_dir(container) + '/startup_complete') if File.exist?(container_state_dir(container) + '/startup_complete')
    true
  end

  def container_cid_file(container)
    SystemConfig.CidDir + '/' + container.container_name + '.cid'
  end

  def delete_container_configs(volbuilder, container)
    cidfile = SystemConfig.CidDir + '/' + container.container_name + '.cid'
    File.delete(cidfile) if File.exist?(cidfile)
    result = volbuilder.execute_command(:remove, {target: container.container_name} )

    FileUtils.rm_rf(container_state_dir(container))
    SystemUtils.run_system('/opt/engines/system/scripts/system/clear_container_dir.sh ' + container.container_name)
    true
  end

  def destroy_container(container)
    return File.delete(container_cid_file(container)) if File.exist?(container_cid_file(container))
    true # File may or may not exist
  end

  def container_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end

  def container_ssh_keydir(container)

    SystemConfig.SSHStore + '/' + container.ctype + 's/' + container.container_name
  end

  def clear_cid_file(container)
    cidfile = container_cid_file(container)
    File.delete(cidfile) if File.exist?(cidfile)
    true
  end

  def container_service_dir(service_name)
    SystemConfig.RunDir + '/services/' + service_name
  end

  def container_disabled_service_dir(service_name)
    SystemConfig.RunDir + '/services-disabled/' + service_name
  end

  def container_state_dir(container)
    SystemConfig.RunDir + '/' + container.ctype + 's/' + container.container_name
  end

end
