module SmServiceControl
  #@ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  #@ All are added to the ManagesEngine/Service Tree
  #@ return true if successful or false if failed
  # no_engien used by  service builder it ignore no engine error
  def create_and_register_service(service_hash, no_engine = false)
    clear_error
    SystemUtils.debug_output(  :sm_create_and_register_service, service_hash)
    #register with Engine
    unless ServiceDefinitions.is_soft_service?(service_hash) 
      test_registry_result(system_registry_client.add_to_managed_engines_registry(service_hash))
      # FIXME not checked because of builder createing services prior to engine
      SystemUtils.debug_output(  :create_and_register_service_register, service_hash)
    end
    return true if service_hash.key?(:shared) && service_hash[:shared] == true
    # add to service and register with service
    if ServiceDefinitions.is_service_persistent?(service_hash)
      SystemUtils.debug_output(  :create_and_register_service_persistr, service_hash)
      return log_error_mesg('Failed to create persistent service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(system_registry_client.add_to_services_registry(service_hash))
    else
      SystemUtils.debug_output(  :create_and_register_service_nonpersistr, service_hash)
      return log_error_mesg('Failed to create non persistent service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(system_registry_client.add_to_services_registry(service_hash))
    end
    return true
  rescue Exception=>e
    puts e.message
    log_exception(e)
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def delete_service(service_query)
    clear_error
    complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
    service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
    return log_error_mesg('Failed to match params to registered service',service_hash) unless service_hash
    service_hash[:remove_all_data] = service_query[:remove_all_data]
    return log_error_mesg('Failed to remove from managed service',service_hash) unless remove_from_managed_service(service_hash) || service_query.key?(:force)
    return log_error_mesg('Failed to remove from managed service registry',service_hash) unless system_registry_client.remove_from_managed_engines_registry(service_hash)
    return log_error_mesg('Failed to remove managed service from services registry', service_hash) unless test_registry_result(system_registry_client.remove_from_services_registry(service_hash))
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def update_attached_service(params)
    clear_error
    ServiceDefinitions.set_top_level_service_params(params,params[:parent_engine])
    if test_registry_result(system_registry_client.update_attached_service(params))
      return add_to_managed_service(params) if remove_from_managed_service(params)
      # this calls add_to_managed_service(params) plus adds to reg
      @last_error='Failed to remove ' + system_registry_client.last_error.to_s
    else
      @last_error = system_registry_client.last_error.to_s
    end
    return false
  rescue StandardError => e
    log_exception(e)
  end

end