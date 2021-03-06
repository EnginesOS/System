require '/opt/engines/lib/ruby/containers/store/cache'

class ContainerApi
  def web_sites_for(container)
    core.web_sites_for(container)
  end

  def initialize_container_env(container)
    container.environments = [] unless container.environments.is_a?(Array)
    set_locale_env(container)
    replace_or_add_if_new(container.environments, {
      name: 'external_domain_name',
      value: default_domain,
      immutable: false})
    replace_or_add_if_new(container.environments, {
      name: 'Engines_Debug_Run',
      value: false ,
      immutable: false}
    )
  end

  def replace_or_add_if_new(environments, env_hash)
    d_set = false
    environments.each do |env|
      if env.name == env_hash[:name]
        env.value = env_hash[:value]
        d_set = true
        break
      end
    end
    environments.push(EnvironmentVariable.new(env_hash)) if d_set.nil?
  end

  def get_container_memory_stats(container)
    MemoryStatistics.get_container_memory_stats(container)
  end

  def delete_engine(container)
    #   SystemDebug.debug(SystemDebug.containers,  :container_api_delete_engine, container)
    Container::Cache.instance.remove(container.container_name)
    volbuilder = core.loadManagedUtility('fsconfigurator')
    system_api.delete_container_configs(volbuilder, container)
  end

  def get_container_network_metrics(container)
    system_api.get_container_network_metrics(container)
  end

  def save_container(container)
    system_api.save_container(container)
  end

  def save_container_log(container, options)
    system_api.save_container_log(container, options)
  end

  def default_domain
    core.default_domain
  end

  def pre_start_checks(container)
    r = true
    unless have_enough_ram?(container)
      r = "Free memory#{system_api.available_ram} Required:#{memory_required(container)}\n"
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
          unless (pa = core.is_port_available?(mp[:external])).is_a?(TrueClass)
          r = "Port clash with #{pa} over Port #{mp[:external]}"
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
          core.register_port(container_name, port)
        end
      end
    end
  end

  def deregister_ports(container_name, mapped_ports)
    unless mapped_ports.nil?
      mapped_ports.values.each do |mp|
        if mp[:publicFacing] = true
          port = mp[:port]
          core.deregister_port(container_name, port)
        end
      end
    end
  end

  def memory_required(container)
    SystemConfig.MinimumFreeRam.to_i + container.memory.to_i * 0.7
  end

  def have_enough_ram?(container)
    if system_api.available_ram > memory_required(container)
      true
    else
      false
    end
  end

  def create_container(container)
    clear_error
    container.expire_engine_info
    raise EnginesException.new(warning_hash('Failed To create container exists by the same name', container.store_address)) if container.ctype != 'system_service' && container.has_container?
    raise EnginesException.new(error_hash('Failed to create state files', container.store_address)) unless ContainerStateFiles.create_container_dirs(container.store_address)
    ContainerStateFiles.clear_cid_file(container.store_address)
    ContainerStateFiles.clear_container_var_run(container.store_address)
    start_dependancies(container) if container.dependant_on.is_a?(Hash)
    container.pull_image if container.ctype != 'app'
    docker_api.create_container(container)    
  end

#  def container_cid_file(ca)
#    system_api.container_cid_file(ca)
#  end

  def run_cronjob(cronjob, container)
    if container.is_running?
      cron_entry = core.retreive_cron_entry(cronjob, container)
      # STDERR.puts(' retreive cron entry from engine registry ' + cron_entry.to_s + ' from ' + cronjob.to_s )
      raise EnginesException.new(error_hash('nil cron line ' + cronjob.to_s )) if cron_entry.nil?
      r = core.exec_in_container({container: container,
        command_line: cron_entry.split(" "),
        log_error: true,
        data: nil,
        timeout:  210})
      raise EnginesException.new(error_hash('Cron job un expected result', r)) unless r.is_a?(Hash)
      "#{r[:stdout]}{[:stderr]}"
    else
      false
    end
  end

  def certificates(container)
    core.containers_certificates(container)
  rescue
    nil
  end

end
