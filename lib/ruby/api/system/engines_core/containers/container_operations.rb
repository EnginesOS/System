module ContainerOperations
  #  def has_container_started?(container_name)
  #    completed_flag_file = SystemConfig.RunDir + '/containers/' + container_name + '/run/flags/startup_complete'
  #    File.exist?(completed_flag_file)
  #  end
  def init_engine_dirs(engine_name)
    @system_api.init_engine_dirs(engine_name)
  end

  def image_exist?(container_name)
    @docker_api.image_exist?(container_name)
  rescue StandardError
    false
  end

  def container_type(container_name)
    if loadManagedEngine(container_name) != false
      'container'
    elsif loadManagedService(container_name) != false
      'service'
    else
      'container' #FIXME poor assumption
    end
  end

  def get_changed_containers
    @system_api.get_changed_containers
  end

  def web_sites_for(container)
    urls = []
    sites = find_engine_services({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'wap',
      container_type: container.ctype
    })
    STDERR.puts('SITES:' + sites.to_s)
    if sites.is_a?(Array)
      sites.each do |site|
        SystemDebug.debug(SystemDebug.containers,  site.to_s) unless  site.is_a?(Hash)
        next unless site.is_a?(Hash) && site[:variables].is_a?(Hash)
        if site[:variables][:proto] == 'http_https'
          protocol = 'http'
        elsif site[:variables][:proto] == 'https_http'
          protocol = 'https'
        else
          protocol = site[:variables][:proto]
          protocol = 'http' if protocol.nil?
        end
        url = protocol.to_s + '://' + site[:variables][:fqdn].to_s
        urls.push(url)
      end
    end
    urls
  end

  def get_container_network_metrics(engine_name)
    engine = @system_api.loadManagedEngine(engine_name)
    unless engine.is_a?(ManagedEngine)
      engine = @system_api.loadManagedService(engine_name)
      unless engine.is_a?(ManagedService)
        raise EnginesException.new(error_hash("Failed to load network stats", engine_name))
      end
    end
    engine.get_container_network_metrics
  end

end