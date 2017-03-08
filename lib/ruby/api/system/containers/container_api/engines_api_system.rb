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
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    ContainerStateFiles.delete_container_configs(volbuilder, container)
  end

  def get_container_network_metrics(container)
    @system_api.get_container_network_metrics(container)
  end

  def save_container(container)
    @system_api.save_container(container)
  end

  def have_enough_ram?(container)
    free_ram = @system_api.available_ram
    return free_ram if free_ram.is_a?(EnginesError)
    ram_needed = SystemConfig.MinimumFreeRam .to_i + container.memory.to_i * 0.7
    return true if free_ram > ram_needed
    return false
  end

  def create_container(container)
    clear_error
    return log_error_mesg('Failed To create container exists by the same name', container) if container.ctype != 'system_service' && container.has_container?
    return log_error_mesg('Failed to create state files', self) unless ContainerStateFiles.create_container_dirs(container)
    ContainerStateFiles.clear_cid_file(container)
    ContainerStateFiles.clear_container_var_run(container)
    start_dependancies(container) if container.dependant_on.is_a?(Hash)
    container.pull_image if container.ctype != 'container'
    r = @docker_api.create_container(container)
    return r if r.is_a?(EnginesDockerError)
     return true
  rescue StandardError => e
    container.last_error = ('Failed To Create ' + e.to_s)
    log_exception(e)
  end

  def container_cid_file(container)
    @system_api.container_cid_file(container)
  end
  
  def run_cronjob(cronjob, container)
     return false unless container.is_running?
   
    #retreive cron entry from engine registry
    cron_entry = @engines_core.retreive_cron_entry(cronjob, container)
    STDERR.puts(' retreive cron entry from engine registry ' + cron_entry.to+s + ' from ' + cronjob.to_s )
     return false if cron_entry.is_a?(EnginesError)
    r = @engines_core.exec_in_container({:container => container, :command_line => cron_entry.split(" "), :log_error => true, :data=>nil })    
     return r.to_s if r.is_a?(EnginesError)
     return r[:stdout] + r[:stderr]
    rescue StandardError => e
       container.last_error = ('Failed ro run cron ' +  cron_entry.to_s + ' ' + e.to_s)
       log_exception(e)
  end

  def certificates(container)
    @engines_core.containers_certificates(container)
  
  end
  
end