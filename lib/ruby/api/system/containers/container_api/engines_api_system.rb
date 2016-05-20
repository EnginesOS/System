module EnginesApiSystem
  def web_sites_for(container)
    engines_core.web_sites_for(container)
  end

  def get_container_memory_stats(container)
    MemoryStatistics.get_container_memory_stats(container)
  end
  
  def delete_engine(container)
    SystemDebug.debug(SystemDebug.containers,  :container_api_delete_engine,container)
    @system_api.delete_engine(container)
    ContainerStateFiles.delete_container_configs(container)
  end

  def get_container_network_metrics(container)
    test_system_api_result(@system_api.get_container_network_metrics(container.container_name))
  end

  def save_container(container)
    test_system_api_result(@system_api.save_container(container))
  end

  def have_enough_ram?(container)
    free_ram = @system_api.avaiable_ram
    ram_needed = SystemConfig.MinimumFreeRam .to_i + container.memory.to_i * 0.7
    return true if  free_ram > ram_needed
    return false
  end

  def create_container(container)
    clear_error
    return log_error_mesg('Failed To create container exists by the same name', container) if container.ctype != 'system_service' && container.has_container?
    ContainerStateFiles.clear_cid_file(container)
    ContainerStateFiles.clear_container_var_run(container)
    start_dependancies(container) if container.dependant_on.is_a?(Hash)
    container.pull_image if container.ctype != 'container'
    r = @docker_api.create_container(container)
    STDERR.puts(' DOCKER api CREATE ' + r.to_s)
    return r if r.is_a?(EnginesDockerError)
    
    return true if ContainerStateFiles.create_container_dirs(container)
   log_error_mesg('Failed to create state files', self)
   
  rescue StandardError => e
    container.last_error = ('Failed To Create ' + e.to_s)
    log_exception(e)
  end

  def container_cid_file(container)
    @system_api.container_cid_file(container)
  end

end