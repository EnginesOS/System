module EngineServiceOperations
  require_relative 'service_manager_access.rb'
  def engine_persistent_services(container_name)
    params = {
      parent_engine:  container_name,
      persistent:  true,
      container_type: 'container'
    }
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, params)
    service_manager.get_engine_persistent_services(params)
  end

  def engines_services_to_backup(engine_name)
    #   STDERR.puts('Backup for ' + engine_name )
    engine_persistent_services(engine_name)
  end

  def service_persistent_services(service_name)
    params = {
      parent_engine: service_name,
      persistent: true,
      container_type: 'service'
    }
    SystemDebug.debug(SystemDebug.services,  :engine_persistent_services, params)
    service_manager.get_engine_persistent_services(params)
  end

  def service_attached_services(service_name)
    find_engine_services_hashes({
      parent_engine: service_name,
      container_type: 'service'
    })
  end

  def engine_attached_services(container_name)
     find_engine_services_hashes({
      parent_engine: container_name,
      container_type: 'container'
    })
  end

  def service_is_registered?(service_hash)
    check_service_hash(service_hash)
    service_manager.service_is_registered?(service_hash)
  end

  def get_engine_persistent_services(service_hash)
    check_engine_hash(service_hash)
    service_manager.get_engine_persistent_services(service_hash)
  end

  def find_engine_services(service_query)
    check_engine_hash(service_query)
    find_engine_services_hashes(service_query)
    #return sm.find_engine_services(params)
  end

  def share_service_to_engine(params)
    SystemDebug.debug(SystemDebug.services,'core attach existing service', params)
    check_engine_hash(params)
    service_manager.share_service_to_engine(params)
  end

  def connect_share_service(service_hash)
    params =  service_hash.dup
    unless service_hash.key?(:existing_service)
      existing = service_hash
      existing[:parent_engine] = existing[:owner]
      existing = get_service_entry(existing)
      params[:existing_service] = existing
    end
    trim_to_editable_variables(params[:existing_service])
    params[:variables].keys do | k |
      next unless params[:existing_service][:variables].keys(k)
      params[:variables][k] = params[:existing_service][:variables][k]
    end
    r = share_service_to_engine(params)
    if service_hash[:type_path] == 'filesystem/local/filesystem'
      add_file_share(params)
    end
    r
  end

  def add_file_share(service_hash)
    SystemDebug.debug(SystemDebug.services, service_hash[:variables][:name].to_s + ' ' + service_hash.to_s)
    # service_hash = Volume.complete_service_hash(service_hash)

    SystemDebug.debug(SystemDebug.services,'complete_VOLUME_FOR SHARE_service_hash', service_hash)
  #  STDERR.puts('Add File Service ' + service_hash.to_s)
    # FixME when building an exception is ok, but not once the engine is running
    begin #on build this fails which is ok
      engine = loadManagedEngine(service_hash[:parent_engine])
      engine.add_shared_volume(service_hash)
    rescue
      
    end
  end

  def trim_to_editable_variables(params)
    variables = SoftwareServiceDefinition.consumer_params(params)
    variables.values do |variable |
      key = variable[:name]
      params[:variables].delete(key) if variable[:immutable] == true
    end
  end

  def get_service_pubkey(engine, cmd)
    container = loadManagedService(engine)
    return service_manager.load_service_pubkey(container, cmd) unless container.is_running?
    args = ['/home/get_pubkey.sh', cmd]
    result = exec_in_container({:container => container, :command_line => args, :log_error => true, :timeout =>30 , :data=>''})
    return result[:stdout] if result.is_a?(Hash) &&result[:result] == 0
    log_error_mesg('Get pub key failed',result)
    service_manager.load_service_pubkey(container, cmd)
  end

  

end