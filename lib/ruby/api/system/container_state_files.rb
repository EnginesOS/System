class ContainerStateFiles
  
  
  def self.build_running_service(service_name, service_type_dir)
    config_template_file_name = service_type_dir + service_name + '/config.yaml'
    return SystemUtils.log_error_mesg('Running exits', service_name) unless File.exist?(config_template_file_name)
    config_template = File.read(config_template_file_name)
    templator = Templater.new(SystemAccess.new, nil)
    running_config = templator.process_templated_string(config_template)
    yam1_file_name = service_type_dir + service_name + '/running.yaml'
    yaml_file = File.new(yam1_file_name, 'w+')
    yaml_file.write(running_config)
    yaml_file.close
    return true
    rescue StandardError => e
       SystemUtils.log_exception(e)
  end
 
  def self.read_container_id(container)
     cidfile = ContainerStateFiles.container_cid_file(container)
     return File.read(cidfile) if File.exist?(cidfile)
   rescue StandardError => e
     SystemUtils.log_exception(e)
     return '-1'
   end

  def self.create_container_dirs(container)
    state_dir = ContainerStateFiles.container_state_dir(container)
    unless File.directory?(state_dir)
      Dir.mkdir(state_dir)
      Dir.mkdir(state_dir + '/run') unless Dir.exist?(state_dir + '/run')       
      Dir.mkdir(state_dir + '/run/flags') unless Dir.exist?(state_dir + '/run/flags')
      FileUtils.chown_R(nil, 'containers', state_dir + '/run')
      FileUtils.chmod_R('u+r', state_dir + '/run')
    end
    log_dir = ContainerStateFiles.container_log_dir(container)
    Dir.mkdir(log_dir) unless File.directory?(log_dir)
    if container.is_service?
      Dir.mkdir(state_dir + '/configurations/') unless File.directory?(state_dir + '/configurations')
      Dir.mkdir(state_dir + '/configurations/default') unless File.directory?(state_dir + '/configurations/default')
    end   
    return true 
  rescue StandardError => e
    container.last_error = 'Failed To Create ' + e.to_s
    SystemUtils.log_exception(e)
  end
  
  def self.clear_container_var_run(container)
    File.unlink(ContainerStateFiles.container_state_dir(container) + '/startup_complete') if File.exist?(ContainerStateFiles.container_state_dir(container) + '/startup_complete')
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
  def self.container_cid_file(container)
        SystemConfig.CidDir + '/' + container.container_name + '.cid'
      end
    
  def self.delete_container_configs(container)
    cidfile = SystemConfig.CidDir + '/' + container.container_name + '.cid'
    File.delete(cidfile) if File.exist?(cidfile)
    cmd = 'docker rm volbuilder'
    retval = SystemUtils.run_system(cmd)
    cmd = 'docker run  --name volbuilder --memory=20m -e fw_user=www-data  -v /opt/engines/run/containers/' + container.container_name + '/:/client/state:rw  -v /var/log/engines/containers/' + container.container_name + ':/client/log:rw    -t engines/volbuilder:' + SystemUtils.system_release + ' /home/remove_container.sh state logs'
    retval = SystemUtils.run_system(cmd)
    cmd = 'docker rm volbuilder'
    retval =  SystemUtils.run_system(cmd)
    if retval == true
      FileUtils.rm_rf(ContainerStateFiles.container_state_dir(container))
      return true
    else
      container.last_error = 'Failed to Delete state and logs:' + retval.to_s
      SystemUtils.log_error_mesg('Failed to Delete state and logs:' + retval.to_s, container)
    end
  rescue StandardError => e
    container.last_error = 'Failed To Delete '
    SystemUtils.log_exception(e)
  end
  
  def self.destroy_container(container)
     container.container_id = -1
     return File.delete(ContainerStateFiles.container_cid_file(container)) if File.exist?(ContainerStateFiles.container_cid_file(container))
     return true # File may or may not exist
   rescue StandardError => e
     container.last_error = 'Failed To delete cid ' + e.to_s
     SystemUtils.log_exception(e)
   end

   def self.container_log_dir(container)
     SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
   end

  def self.clear_cid_file(container)
     cidfile = container_cid_file(container)
     File.delete(cidfile) if File.exist?(cidfile)
     return true
   rescue StandardError => e
     container.last_error = 'Failed To remove cid file' + e.to_s
     SystemUtils.log_exception(e)
   end 
   
  def self.container_state_dir(container)
      SystemConfig.RunDir + '/' + container.ctype + 's/' + container.container_name
    end 
end
