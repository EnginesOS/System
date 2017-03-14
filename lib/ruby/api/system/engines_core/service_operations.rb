module ServiceOperations

  require_relative 'service_manager_access.rb'
  def signal_service_process(pid, sig, name)
    clear_error
    container = loadManagedService(name)
    @docker_api.signal_container_process(pid, sig, container)
  end

  def force_reregister_attached_service(service_query)
    r = ''
    return r unless (r = check_service_hash(service_query))
    service_manager.force_reregister_attached_service(service_query)
  end

  def force_deregister_attached_service(service_query)
    r = ''
    return r unless (r = check_service_hash(service_query))
    service_manager.force_deregister_attached_service(service_query)
  end

  def force_register_attached_service(service_query)
    r = ''
    return r unless (r = check_service_hash(service_query))
    service_manager.force_register_attached_service(service_query)
  end

  # @return an [Array] of service_hashs of Active persistent services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistent_services(params)
    service_manager.get_active_persistent_services(params)
  end

  #Attach the service defined in service_hash [Hash]
  #@return boolean indicating sucess
  def create_and_register_service(service_hash)
    r = ''
  #  service_hash = SystemUtils.symbolize_keys(service_hash)

    SystemDebug.debug(SystemDebug.services, :attach_ing_create_and_egister_service, service_hash)
    return r unless ( r = create_and_register_managed_service(service_hash))

    true
  rescue StandardError => e
    log_exception(e)
  end

  def dettach_service(service_hash)
    r = ''
    return r unless (r = check_service_hash(service_hash))
    SystemDebug.debug(SystemDebug.services,:dettach_service, service_hash)
    service_manager.delete_service(service_hash)
  rescue StandardError => e
    log_exception(e)
  end

  # @ returns  complete service hash matching PNS,SP,PE,SH
  def retrieve_service_hash(query_hash)
    find_engine_service_hash(query_hash)
  end

  def list_providers_in_use
    service_manager.list_providers_in_use
  end

  #returns
  def find_service_consumers(service_query)
    r = ''
    return r unless (r = check_service_hash(service_query))
    service_manager.find_service_consumers(service_query)
  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(service_hash)
    r = ''
    clear_error
    return r unless (r = check_service_hash(service_hash))
    service_manager.get_registered_against_service(service_hash)
  end

  def update_attached_service(service_hash)
    clear_error
    r = ''
    return false unless (r = check_engine_service_hash(service_hash))

    ahash = find_engine_service_hash(service_hash)
    return ahash if ahash.is_a?(EnginesError)
    return log_error_mesg("Cannot update a shared service",service_hash) if ahash[:shared] == true
    service_manager.update_attached_service(service_hash)
  end

  def clear_service_from_registry(service, persistence=:non_persistent)
    service_manager.clear_service_from_registry({:parent_engine => service.container_name, :container_type => 'service', :persistence => persistence})
  end

  protected

  def create_and_register_managed_service(service_hash)
    r = ''
    return log_error_mesg('Attached Service passed no variables ' +  service_hash.to_s, service_hash) unless service_hash.key?(:variables)
    SystemDebug.debug(SystemDebug.services, "osapicreate_and_register_managed_service", service_hash)
    service_hash[:variables][:parent_engine] = service_hash[:parent_engine] unless service_hash[:variables].has_key?(:parent_engine)
    ServiceDefinitions.set_top_level_service_params(service_hash, service_hash[:parent_engine])

    return r unless ( r = check_engine_service_hash(service_hash))

    if service_hash[:type_path] == 'filesystem/local/filesystem'
      engine = loadManagedEngine(service_hash[:parent_engine])
      engine.add_volume(service_hash) if engine.is_a?(ManagedEngine)
    end
    SystemDebug.debug(SystemDebug.services,"calling service ", service_hash)
    return service_manager.create_and_register_service(service_hash)
  end

end