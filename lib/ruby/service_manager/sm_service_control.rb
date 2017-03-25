module SmServiceControl
  # @ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  # @ All are added to the ManagesEngine/Service Tree
  # @ return true if successful or false if failed
  # no_engien used by  service builder it ignore no engine error
  def create_and_register_service(service_hash) # , no_engine = false)
    clear_error
    SystemDebug.debug(SystemDebug.services, :sm_create_and_register_service, service_hash)
    #register with Engine
    unless is_soft_service?(service_hash)
      system_registry_client.add_to_managed_engines_registry(service_hash)
      # FIXME not checked because of builder createing services prior to engine
      SystemDebug.debug(SystemDebug.services, :create_and_register_service_register, service_hash)
    end
    return true if service_hash.key?(:shared) && service_hash[:shared] == true
    # add to service and register with service
    if is_service_persistent?(service_hash)
      SystemDebug.debug(SystemDebug.services, :create_and_register_service_persistr, service_hash)
      add_to_managed_service(service_hash)
       system_registry_client.add_to_services_registry(service_hash)
    else
      SystemDebug.debug(SystemDebug.services, :create_and_register_service_nonpersistr, service_hash)
     add_to_managed_service(service_hash)
       system_registry_client.add_to_services_registry(service_hash)
    end
    true
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  # @return false
  def delete_and_remove_service(service_query)
    clear_error
    complete_service_query = set_top_level_service_params(service_query,service_query[:parent_engine])
      STDERR.puts('delete_service ' + complete_service_query.to_s)
    service_hash = retrieve_engine_service_hash(complete_service_query)
    return service_hash unless service_hash.is_a?(Hash)

    if service_hash[:shared] == true
      return remove_shared_service_from_engine(service_query)     
      #  return system_registry_client.remove_from_managed_engine(service_hash)
    end
    service_hash[:remove_all_data] = service_query[:remove_all_data]
    remove_from_managed_service(service_hash) ## continue if service_query.key?(:force)
    system_registry_client.remove_from_managed_engine(service_hash)
    system_registry_client.remove_from_services_registry(service_hash)
  end

  def update_attached_service(params)
    clear_error
    set_top_level_service_params(params,params[:parent_engine])
    system_registry_client.update_attached_service(params)
    remove_from_managed_service(params)
    add_to_managed_service(params)   
  end

  def clear_service_from_registry(service)
    system_registry_client.clear_service_from_registry(service)
  end
end