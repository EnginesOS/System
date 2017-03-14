#Calls on service on the service_container to add the service associated by the hash
#@return result boolean
#@param service_hash [Hash]
def add_to_managed_service(service_hash)
  clear_error
  result = false
  SystemDebug.debug(SystemDebug.services, :add_to_managed_service, service_hash)
  service =  @core_api.load_software_service(service_hash)
  return service unless service.is_a?(ManagedService)
  return true if service.is_soft_service? && !service.is_running?
  return log_error_mesg('Cant add to service if service is stopped: ' + service.container_name.to_s ,service_hash) unless service.is_running? 
  SystemDebug.debug(SystemDebug.services, :add_to_managed_service, service)
  r = service.add_consumer(service_hash)
  SystemDebug.debug(SystemDebug.services, :add_to_managed_result, r)
  r
rescue StandardError => e
  log_exception(e)
end

# Calls remove service on the service_container to remove the service associated by the hash
# @return result boolean
# @param service_hash [Hash]
# remove persistent services only if service is up
def remove_from_managed_service(service_hash)
  clear_error
  service =  @core_api.load_software_service(service_hash)
  return service unless service.is_a?(ManagedService)
  return service.remove_consumer(service_hash) if service.persistent == false || service.is_running?
  return log_error_mesg('Cant remove persistent service if service is stopped ', service_hash) if service.persistent
  true
rescue StandardError => e
  log_exception(e)
end