module ManagedServiceDirectActions
  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to register the service hash with service
  # nothing is written to the service registry
  # effectivitly activating non persistent services
  def register_attached_service(service_query)
    SystemDebug.debug(SystemDebug.services, :register_attached_service, service_query)
    return success(service_query[:parent_engine].to_s + ' ' + service_query[:service_handle].to_s, 'Register Service') if @core_api.force_register_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'deregister_attached_service failed ')
  end

  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to deregister the service hash from service
  # nothing is written to the service resgitry
  def deregister_attached_service(service_query)
    SystemDebug.debug(SystemDebug.services,:deregister_attached_service, service_query)
    return success(service_query[:parent_engine].to_s + ' ' + service_query[:service_handle].to_s, 'Deregister Service') if @core_api.force_deregister_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'deregister_attached_service failed ')
  end

  # @ return [EnginesOSapiResult]
  # @params service_hash
  # this method is called to deregister the service hash from service
  # and then to register the service_hash with the service
  # nothing is written to the service resgitry
  def reregister_attached_service(service_query)
    SystemDebug.debug(SystemDebug.services, :reregister_attached_service, service_query)
    return success(service_query[:parent_engine].to_s + ' ' +service_query[:service_handle].to_s, 'reregister Service') if @core_api.force_reregister_attached_service(service_query)
    failed(service_query.to_s, @last_error, 'reregister_attached_service failed ')
  end
end