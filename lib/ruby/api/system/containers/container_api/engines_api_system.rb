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
    ram_needed = SystemConfig.MinimumFreeRam .to_i + container.memory.to_i * 0.7
    return false if free_ram < ram_needed
    true
  end

  def create_container(container)
    clear_error
    raise EnginesException.new(error_hash('Failed To create container exists by the same name', container)) if container.ctype != 'system_service' && container.has_container?
    raise EnginesException.new(error_hash('Failed to create state files', self)) unless ContainerStateFiles.create_container_dirs(container)
    ContainerStateFiles.clear_cid_file(container)
    ContainerStateFiles.clear_container_var_run(container)
    start_dependancies(container) if container.dependant_on.is_a?(Hash)
    container.pull_image if container.ctype != 'container'
    @docker_api.create_container(container) 
  end

  def container_cid_file(container)
    @system_api.container_cid_file(container)
  end

  def run_cronjob(cronjob, container)
    return false unless container.is_running?
    cron_entry = @engines_core.retreive_cron_entry(cronjob, container)
    # STDERR.puts(' retreive cron entry from engine registry ' + cron_entry.to_s + ' from ' + cronjob.to_s )
    raise EnginesException.new(error_hash('nil cron line ' + cronjob.to_s )) if cron_entry.nil?
    r = @engines_core.exec_in_container({:container => container, :command_line => cron_entry.split(" "), :log_error => true, :data=>nil })
    raise EnginesException.new(error_hash('Cron job un expected result', r)) unless r.is_a?(Hash)
    r[:stdout] + r[:stderr]
  end

  def certificates(container)
    @engines_core.containers_certificates(container)
  rescue
    nil
  end

end