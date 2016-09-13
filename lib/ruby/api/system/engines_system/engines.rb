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
  
  def init_engine_dirs(engine)
     FileUtils.mkdir_p(ContainerStateFiles.container_state_dir(engine_name) + '/run') unless Dir.exist?(ContainerStateFiles.container_state_dir(engine_name)+ '/run')
     FileUtils.mkdir_p(ContainerStateFiles.container_log_dir(engine_name)) unless Dir.exist?(ContainerStateFiles.container_log_dir(engine_name))
    FileUtils.mkdir_p(ContainerStateFiles.container_ssh_keydir(engine_name)) unless Dir.exist?(ContainerStateFiles.container_ssh_keydir(engine_name))
    rescue StandardError => e
      log_exception(e)
    
  end
  
  def set_engine_network_properties(engine, params)
    clear_error
    p :set_engine_network_properties
    p engine.container_name
    p params
    r = ''
    return set_engine_hostname_details(engine, params) if ( r = set_engine_web_protocol_properties(engine, params))
    return r
  end

  def set_engine_web_protocol_properties(engine, params)
    clear_error
    p :set_engine_web_protocol_properties
    p engine.container_name
    p params
    protocol = params[:http_protocol]
    return log_error_mesg('no protocol field') if protocol.nil?
    protocol.downcase
    protocol.gsub!(/ /,"_")
    SystemDebug.debug(SystemDebug.services,'Changing protocol to _', protocol)
    if protocol.include?('https_only')
      engine.enable_https_only
    elsif protocol.include?('http_only')
      engine.enable_http_only
    elsif protocol.include?('https_and_http')
      engine.enable_http_and_https
    end
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def set_engine_hostname_details(container, params)
    clear_error
#    p :set_engine_network_properties
#    p container.container_name
#    p params
    #FIXME [:hostname]  silly host_name from gui drop it
    if params.key?(:host_name)
      hostname = params[:host_name]
    else
      hostname = params[:hostname] 
    end
    
    domain_name = params[:domain_name]
    SystemDebug.debug(SystemDebug.services,'Changing Domainame to ', domain_name)
    
    container.remove_nginx_service
    container.set_hostname_details(hostname, domain_name)
    container.save_state
   # save_container(container)
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
    return log_error_mesg('Nil Engine Name', engine_name) if engine_name.nil?
    e = engine_from_cache(engine_name)
    return e if e.is_a?(ManagedEngine)

    return log_error_mesg('No Engine name', engine_name) if engine_name.nil? || engine_name.length == 0
    yaml_file_name = SystemConfig.RunDir + '/containers/' + engine_name + '/running.yaml'
    return log_error_mesg('No Engine file', engine_name) unless File.exist?(yaml_file_name)
    return log_error_mesg('Engine File Locked',yaml_file_name) if is_container_conf_file_locked?(SystemConfig.RunDir + '/containers/' + engine_name)
    yaml_file = File.read(yaml_file_name)
    ts = File.mtime(yaml_file_name)
    managed_engine = ManagedEngine.from_yaml(yaml_file, @engines_api.container_api)
    return managed_engine if managed_engine.nil? || managed_engine.is_a?(EnginesError)
    cache_engine(managed_engine, ts)
    return managed_engine
  rescue StandardError => e
#    unless engine_name.nil?
#      unless managed_engine.nil?
#        managed_engine.last_error = 'Failed To get Managed Engine ' + engine_name + ' ' + e.to_s
#        log_error_mesg(managed_engine.last_error, e)
#      end
#    else
#      log_error_mesg('nil Engine Name', engine_name)
#    end
    log_error_mesg('nil Engine Name', engine_name)
    log_exception(e)
  end
  

  def delete_engine(container)
    
    rm_engine_from_cache(container.container_name)
   
  end
  
end