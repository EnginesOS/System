#Calls on service on the service_container to add the service associated by the hash
#@return result boolean
#@param service_hash [Hash]
def add_to_managed_service(service_hash)
  clear_error
  result = false
  service =  @core_api.load_software_service(service_hash)
  return service if service.is_a?(EnginesError)
  return true if  service.is_soft_service? && !service.is_running?
  return log_error_mesg('Cant add to service if service is stopped: ' + service.container_name.to_s ,service_hash) unless service.is_running? 
 
  SystemDebug.debug(SystemDebug.services, :add_to_managed_service, service_hash)
  return log_error_mesg('Failed to add Consumser to Service, as service not running',service_hash) unless service.is_running?
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
    
  if service.persistent == false || service.is_running?
    return  service.remove_consumer(service_hash)   
  elsif service.persistent
    return log_error_mesg('Cant remove persistent service if service is stopped ', service_hash)
  else
     true
  end
rescue StandardError => e
  log_exception(e)
end