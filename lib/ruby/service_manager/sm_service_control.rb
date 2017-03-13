module SmServiceControl
  #@ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  #@ All are added to the ManagesEngine/Service Tree
  #@ return true if successful or false if failed
  # no_engien used by  service builder it ignore no engine error
  def create_and_register_service(service_hash, no_engine = false)
    clear_error
    r = ''
    SystemDebug.debug(SystemDebug.services, :sm_create_and_register_service, service_hash)
    #register with Engine
    unless ServiceDefinitions.is_soft_service?(service_hash) 
      system_registry_client.add_to_managed_engines_registry(service_hash)
      # FIXME not checked because of builder createing services prior to engine
      SystemDebug.debug(SystemDebug.services, :create_and_register_service_register, service_hash)
    end
    return true if service_hash.key?(:shared) && service_hash[:shared] == true
    # add to service and register with service
    if ServiceDefinitions.is_service_persistent?(service_hash)
      SystemDebug.debug(SystemDebug.services,  :create_and_register_service_persistr, service_hash)
      return r if ( r = add_to_managed_service(service_hash)).is_a?(EnginesError)
      return system_registry_client.add_to_services_registry(service_hash)
    else
      SystemDebug.debug(SystemDebug.services,  :create_and_register_service_nonpersistr, service_hash)
      r = add_to_managed_service(service_hash)
      return r if r.is_a?(EnginesError)
      return system_registry_client.add_to_services_registry(service_hash)
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
    r = ''
    complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      return complete_service_query if complete_service_query.is_a?(EnginesError)
    service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
    return service_hash unless service_hash.is_a?(Hash)

    if service_hash[:shared] == true
      SystemDebug.debug(SystemDebug.services,  :delete_shared_service, service_hash)
      r =  remove_shared_service_from_engine(service_query)
      SystemDebug.debug(SystemDebug.services,  :DELETED_shared_service, service_hash)
      return r
      #  return system_registry_client.remove_from_managed_engines_registry(service_hash)       
    end
   # return log_error_mesg('Failed to match params to registered service',service_hash) unless service_hash.is_a?(Hash)
    service_hash[:remove_all_data] = service_query[:remove_all_data]
    return log_error_mesg(' missing ns ',service_hash) unless service_hash.key?(:publisher_namespace) && service_hash.key?(:type_path) 
    return r if (r = remove_from_managed_service(service_hash)).is_a?(EnginesError) && !service_query.key?(:force)
    return r if ( r = system_registry_client.remove_from_managed_engines_registry(service_hash)).is_a?(EnginesError)
    return system_registry_client.remove_from_services_registry(service_hash)

  rescue StandardError => e
    log_exception(e)
  end

  def update_attached_service(params)
    clear_error
    r = ''
    ServiceDefinitions.set_top_level_service_params(params,params[:parent_engine])
    if (r = system_registry_client.update_attached_service(params))
      return add_to_managed_service(params) if ( r = remove_from_managed_service(params))
        return r
      # this calls add_to_managed_service(params) plus adds to reg
      @last_error='Failed to remove ' + system_registry_client.last_error.to_s
    else
      @last_error = system_registry_client.last_error.to_s
    end
    return r
  rescue StandardError => e
    log_exception(e)
  end
  
  def clear_service_from_registry(service)
    system_registry_client.clear_service_from_registry(service)
  end
end