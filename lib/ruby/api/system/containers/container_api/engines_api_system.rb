module EnginesApiSystem
  def web_sites_for(container)
    engines_core.web_sites_for(container)
  end

  def get_container_memory_stats(container)
    MemoryStatistics.get_container_memory_stats(container)
  end

  def delete_engine(container)
    SystemDebug.debug(SystemDebug.containers,  :container_api_delete_engine,container)
    @system_api.rm_engine_from_cache(container.container_name)
    volbuilder = @engines_core.loadManagedUtility('fsconfigurator')
    @system_api.delete_container_configs(volbuilder, container)
  end

  def get_container_network_metrics(container)
    @system_api.get_container_network_metrics(container)
  end

  def save_container(container)
    @system_api.save_container(container)
  end

  def  pre_start_checks(container)
    r=true
    unless have_enough_ram?(container)
      r = 'Free memory' + @system_api.available_ram.to_s + ' Required:' + memory_required.to_s + "\n"
    end
    if (c = port_clash?(container.mapped_ports))
      r = c
    end
    r
  end

  def port_clash?(mapped_ports)
    r = false
    unless mapped_ports.nil?
      mapped_ports.values.each do |mp|
        if mp[:publicFacing] == true
          unless (pa = @engines_core.is_port_available?(mp[:external])).is_a?(TrueClass)
            r = 'Port clash with ' + pa + ' over Port ' + mp[:external].to_s
            break
          end
        end
      end
    end
    r
  end

  def register_ports(container_name, mapped_ports)
    unless mapped_ports.nil?
    mapped_ports.values.each do |mp|
      if mp[:publicFacing] == true
        port = mp[:port]
        @engines_core.register_port(container_name, port)
      end
    end
    end
  end

  def deregister_ports(container_name, mapped_ports)
    unless mapped_ports.nil?
    mapped_ports.values.each do |mp|
      if mp[:publicFacing] = true
        port = mp[:port]
        @engines_core.deregister_port(container_name, port)
      end
    end
    end
  end

  def memory_required 
    SystemConfig.MinimumFreeRam.to_i + container.memory.to_i * 0.7  
  end
  
  def have_enough_ram?(container)
    if @system_api.available_ram > memory_required
      true
    else
      false
    end
  end

  def create_container(container)
    clear_error
    raise EnginesException.new(warning_hash('Failed To create container exists by the same name', container)) if container.ctype != 'system_service' && container.has_container?
    raise EnginesException.new(error_hash('Failed to create state files', self)) unless @system_api.create_container_dirs(container)
    @system_api.clear_cid_file(container)
    @system_api.clear_container_var_run(container)
    start_dependancies(container) if container.dependant_on.is_a?(Hash)
    container.pull_image if container.ctype != 'app'
    @docker_api.create_container(container)
  end

  def container_cid_file(container)
    @system_api.container_cid_file(container)
  end

  def run_cronjob(cronjob, container)
    if container.is_running?
      cron_entry = @engines_core.retreive_cron_entry(cronjob, container)
      # STDERR.puts(' retreive cron entry from engine registry ' + cron_entry.to_s + ' from ' + cronjob.to_s )
      raise EnginesException.new(error_hash('nil cron line ' + cronjob.to_s )) if cron_entry.nil?
      r = @engines_core.exec_in_container({:container => container, :command_line => cron_entry.split(" "), :log_error => true, :data => nil})
      raise EnginesException.new(error_hash('Cron job un expected result', r)) unless r.is_a?(Hash)
      r[:stdout] + r[:stderr]
    else
      false
    end
  end

  def certificates(container)
    @engines_core.containers_certificates(container)
  rescue
    nil
  end

end