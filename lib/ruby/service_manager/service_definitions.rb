module ServiceDefinitions


  
 def is_service_persistant?(service_hash)
   unless service_hash.key?(:persistant)
     persist = software_service_persistance(service_hash)
    return log_error_mesg('Failed to get persistance status for ',service_hash)  if persist.nil?
     service_hash[:persistant] = persist
   end
   service_hash[:persistant]  
 rescue StandardError => e
   log_exception(e)
 end

 #load softwwareservicedefinition for serivce in service_hash and
 #@return boolean indicating the persistance
 #@return nil if no software definition found
 def software_service_persistance(service_hash)
   clear_error
   service_definition = software_service_definition(service_hash)
   return service_definition[:persistant] unless service_definition.nil?              
   return nil 
   rescue StandardError => e
     log_exception(e)
 end
 
 
 #Find the assigned service container_name from teh service definition file
 def get_software_service_container_name(params)
   clear_error
   server_service =  software_service_definition(params)
   return log_error_mesg('Failed to load service definitions',params) if server_service.nil? || server_service == false

   return server_service[:service_container]   
   rescue StandardError => e
     log_exception(e)
 end
 
end