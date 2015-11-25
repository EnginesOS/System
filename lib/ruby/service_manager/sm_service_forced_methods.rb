module SmServiceForcedMethods
  require_relative 'service_container_actions.rb'
  def register_non_persistant_service(service_hash)
       ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
       clear_error
      return log_error_mesg('Failed to create persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(system_registry_client.add_to_services_registry(service_hash))
       return true 
       rescue StandardError => e
         log_exception(e)
     end
     
 
  def deregister_non_persistant_service(service_hash)
    clear_error
   return log_error_mesg('Failed to create persistant service ',service_hash) unless remove_from_managed_service(service_hash)
    return log_error_mesg('Failed to deregsiter service from managed service registry',service_hash) unless test_registry_result(system_registry_client.remove_from_services_registry(service_hash))
    return true   
    rescue StandardError => e
      log_exception(e)
  end
  
     def force_register_attached_service(service_query)
      # p service_query.class.name
       complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
       service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
       return log_error_mesg( 'force_reregister no matching service found',service_query) unless service_hash.is_a?(Hash)
       add_to_managed_service(service_hash)     
       rescue StandardError => e
         log_exception(e)
      end
      
    def force_deregister_attached_service(service_query)
    #  p service_query.class.name
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
     return log_error_mesg( 'force_deregister_ no matching service found',service_query) unless service_hash.is_a?(Hash)
     return remove_from_managed_service(service_hash)   
    end
    
    def force_reregister_attached_service(service_query)
    #  p service_query.class.name
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
      return log_error_mesg( 'force_register no matching service found',service_query) unless service_hash.is_a?(Hash)
      return add_to_managed_service(service_hash) if remove_from_managed_service(service_hash) 
     return false   
      rescue StandardError => e
        log_exception(e)
    end

     
   
  
 
 

end