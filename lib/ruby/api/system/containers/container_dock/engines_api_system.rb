require '/opt/engines/lib/ruby/containers/store/cache'

module EnginesApiSystem
  def web_sites_for(container)
    core.web_sites_for(container)
  end

  def initialize_container_env(c)
    c.environments = [] unless c.environments.is_a?(Array)
    set_locale_env(c)
    replace_or_add_if_new(c.environments, {
      name: 'external_domain_name',
      value: default_domain,
      immutable: false})
    replace_or_add_if_new(c.environments, {
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
        next
      end
    end
    environments.push(EnvironmentVariable.new(env_hash)) unless d_set.is_a?(TrueClass)
  end

  def get_container_memory_stats(c)
    MemoryStatistics.get_container_memory_stats(c)
  end

  def delete_engine(c)
    #   SystemDebug.debug(SystemDebug.containers,  :container_dock_delete_engine, container)
    Container::Cache.instance.remove(c.container_name)
    volbuilder = core.loadManagedUtility('fsconfigurator')
    system_api.delete_container_configs(volbuilder, c)
  end

  def get_container_network_metrics(c)
    system_api.get_container_network_metrics(c)
  end

  def save_container(c)
    system_api.save_container(c)
  end

  def save_container_log(c, options)
    system_api.save_container_log(c, options)
  end

  def default_domain
    core.default_domain
  end

  def pre_start_checks(c)
    r = true
    unless have_enough_ram?(c)
      r = "Free memory#{system_api.available_ram} Required:#{memory_required(c)}\n"
    end
    if (p = port_clash?(c.mapped_ports))
      r = p
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

  def memory_required(c)
    SystemConfig.MinimumFreeRam.to_i + c.memory.to_i * 0.7
  end

  def have_enough_ram?(c)
    if system_api.available_ram > memory_required(c)
      true
    else
      false
    end
  end

  def create_container(c)
    clear_error
    c.expire_engine_info
    raise EnginesException.new(warning_hash('Failed To create container exists by the same name', c.store_address)) if c.ctype != 'system_service' && c.has_container?
    raise EnginesException.new(error_hash('Failed to create state files', c.store_address)) unless c.store.create_container_dirs(c.container_name)
    c.store.clear_cid_file(c.container_name)
    c.store.clear_container_var_run(c.container_name)
    start_dependancies(c) if c.dependant_on.is_a?(Hash)
    c.pull_image if c.ctype != 'app'
    dock_face.create_container(c)
  end

  def run_cronjob(cronjob, c)
    if container.is_running?
      cron_entry = core.retreive_cron_entry(cronjob, c)
      # STDERR.puts(' retreive cron entry from engine registry ' + cron_entry.to_s + ' from ' + cronjob.to_s )
      raise EnginesException.new(error_hash('nil cron line ' + cronjob.to_s )) if cron_entry.nil?
      r = dock_face.docker_exec({container: c,
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

  def certificates(c)
    core.containers_certificates(c)
  rescue
    nil
  end

end
