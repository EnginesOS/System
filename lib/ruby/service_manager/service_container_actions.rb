#Calls on service on the service_container to add the service associated by the hash
 #@return result boolean
 #@param service_hash [Hash]
 def add_to_managed_service(service_hash)
   clear_error
   p :add_to_managed_service
   p service_hash
   service =  @core_api.load_software_service(service_hash)
  return log_error_mesg('Failed to load service to add :' +  @core_api.last_error.to_s, service_hash) if service.nil? || service.is_a?(FalseClass)
  return log_error_mesg('Cant add to service if service is stopped ',service_hash) unless service.is_running?
   result = service.add_consumer(service_hash)
  return log_error_mesg('Failed to add Consumser to Service :' +  @core_api.last_error.to_s + ':' + service.last_error.to_s,service_hash) unless result
    return result   
   rescue StandardError => e
     log_exception(e)
 end
 
 def is_service_running?(service_name)
  service =  @core_api.loadManagedService(service_name)
  return false unless service.is_a?(ManagedService)
  return service.is_running? 
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
   p :ready_to_rm
   if service.persistant == false || service.is_running? 
     p :ready_to_rm
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