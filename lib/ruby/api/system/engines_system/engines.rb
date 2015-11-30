module Engines
  def list_managed_engines
    clear_error
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
      yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
      ret_val.push(contdir) if File.exist?(yfn)
    end
    return ret_val
  rescue StandardError => e
    log_exception(e)
    return ret_val
  end

  def set_engine_network_properties(engine, params)
    clear_error
    return set_engine_hostname_details(engine, params) if set_engine_web_protocol_properties(engine, params)
    return false
  end

  def set_engine_web_protocol_properties(engine, params)
    clear_error
    protocol = params[:http_protocol]
    return false if protocol.nil?
    SystemUtils.debug_output('Changing protocol to _', protocol)
    if protocol.include?('HTTPS only')
      engine.enable_https_only
    elsif protocol.include?('HTTP only')
      engine.enable_http_only
    elsif protocol.include?('HTTPS and HTTP')
      engine.enable_http_and_https
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def set_engine_hostname_details(container, params)
    clear_error

    hostname = params[:host_name]
    domain_name = params[:domain_name]
    SystemUtils.debug_output('Changing Domainame to ', domain_name)
    container.remove_nginx_service
    container.set_hostname_details(hostname, domain_name)
    save_container(container)
    container.add_nginx_service
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def getManagedEngines
    ret_val = []
    Dir.entries(SystemConfig.RunDir + '/containers/').each do |contdir|
      yfn = SystemConfig.RunDir + '/containers/' + contdir + '/running.yaml'
      if File.exist?(yfn)
        managed_engine = loadManagedEngine(contdir)
        if managed_engine.is_a?(ManagedEngine)
          ret_val.push(managed_engine)
        else
          log_error_mesg('failed to load ', yfn)
        end
      end
    end
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def loadManagedEngine(engine_name)
    e = engine_from_cache(engine_name)
    return e unless e.nil?

    return log_error_mesg('No Engine name', engine_name) if engine_name.nil? || engine_name.length == 0
    yam_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
    return log_error_mesg('No Engine file', engine_name) unless File.exist?(yam_file_name)
    return log_error_mesg('Engine File Locked',yam_file_name) if is_container_conf_file_locked?(SystemConfig.RunDir + '/containers/' + engine_name)
    yaml_file = File.read(yam_file_name)
    ts = File.mtime(yam_file_name)
    managed_engine = ManagedEngine.from_yaml(yaml_file, @engines_api.container_api)
    return false if managed_engine.nil? || managed_engine == false
    cache_engine( managed_engine, ts)
    return managed_engine
  rescue StandardError => e
    unless engine_name.nil?
      unless managed_engine.nil?
        managed_engine.last_error = 'Failed To get Managed Engine ' + engine_name + ' ' + e.to_s
        log_error_mesg(managed_engine.last_error, e)
      end
    else
      log_error_mesg('nil Engine Name', engine_name)
    end
    log_exception(e)
  end
  

  def delete_engine(container_name)
    rm_engine_from_cache(container_name)
  end
  
end