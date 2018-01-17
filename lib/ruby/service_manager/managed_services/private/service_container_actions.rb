#Calls on service on the service_container to add the service associated by the hash
#@return result boolean
#@param service_hash [Hash]
def add_to_managed_service(service_hash)
  SystemDebug.debug(SystemDebug.services, :add_to_managed_service, service_hash)
  service =  @core_api.load_software_service(service_hash)
  # return service unless service.is_a?(ManagedService)
  if service.is_soft_service? && !service.is_running?
    true
  else
    raise EnginesException.new(error_hash('Cant add to service if service is stopped: ' + service.container_name.to_s, service_hash)) unless service.is_running?
    service.add_consumer(service_hash)
  end
end

def update_on_managed_service(service_hash)
  SystemDebug.debug(SystemDebug.services, :update_on_managed_service, service_hash)
  service =  @core_api.load_software_service(service_hash)
  # return service unless service.is_a?(ManagedService)
  if service.is_soft_service? && !service.is_running?
    true
  else
    raise EnginesException.new(error_hash('Cant update service if service is stopped: ' + service.container_name.to_s, service_hash)) unless service.is_running?
    service.update_consumer(service_hash)
  end
end

# Calls remove service on the service_container to remove the service associated by the hash
# @return result boolean
# @param service_hash [Hash]
# remove persistent services only if service is up
def remove_from_managed_service(service_hash)
  service =  @core_api.load_software_service(service_hash)
  #return service unless service.is_a?(ManagedService)
  if service.persistent == false || service.is_running?
    service.remove_consumer(service_hash)
  else
    raise EnginesException.new(error_hash('Cant remove persistent service if service is stopped ', service_hash)) if service.persistent
  end
end