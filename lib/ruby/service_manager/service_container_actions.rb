#Calls on service on the service_container to add the service associated by the hash
#@return result boolean
#@param service_hash [Hash]
def add_to_managed_service(service_hash)
  clear_error
  result = false
  service =  @core_api.load_software_service(service_hash)
  return log_error_mesg('Failed to load service to add :' +  @core_api.last_error.to_s, service_hash) if service.nil? || service.is_a?(FalseClass)
  return log_error_mesg('Cant add to service if service is stopped ',service_hash) unless (service.is_running? | service.is_soft_service?)
  SystemUtils.debug_output(  :add_to_managed_service, service_hash)
  result = service.add_consumer(service_hash) if service.is_running? 
  puts "service add consumer result " + result.to_s + " amd service_is_running? " + service.is_running?.to_s
  return log_error_mesg('Failed to add Consumser to Service :' +  @core_api.last_error.to_s + ':' + service.last_error.to_s,service_hash) unless result
  return result
rescue StandardError => e
  log_exception(e)
end

# Calls remove service on the service_container to remove the service associated by the hash
# @return result boolean
# @param service_hash [Hash]
# remove persistant services only if service is up
def remove_from_managed_service(service_hash)
  clear_error
  service =  @core_api.load_software_service(service_hash)
  unless service.is_a?(ManagedService)
    return log_error_mesg('Failed to load service to remove + ' + @core_api.last_error.to_s + ' :service ' + service.to_s, service_hash)
  end
  if service.persistant == false || service.is_running?
    return true if service.remove_consumer(service_hash)
    return log_error_mesg('Failed to remove persistant service as consumer service ', service_hash)
  elsif service.persistant
    return log_error_mesg('Cant remove persistant service if service is stopped ', service_hash)
  else
    return true
  end
rescue StandardError => e
  log_exception(e)
end