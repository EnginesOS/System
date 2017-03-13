module SmServiceForcedMethods
  require_relative 'service_container_actions.rb'
  def register_non_persistent_service(service_hash)
       ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
       clear_error
    r = ''
      return r unless ( r = add_to_managed_service(service_hash))
      return test_registry_result(system_registry_client.add_to_services_registry(service_hash))

       rescue StandardError => e
         log_exception(e)
     end
     
  def deregister_non_persistent_service(service_hash)
    clear_error
    r = ''
   return r unless ( r = remove_from_managed_service(service_hash))
    return  test_registry_result(system_registry_client.remove_from_services_registry(service_hash))
    rescue StandardError => e
      log_exception(e)
  end
  
     def force_register_attached_service(service_query)
       complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
       service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
       return log_error_mesg( 'force_reregister no matching service found',service_query) unless service_hash.is_a?(Hash)
       add_to_managed_service(service_hash)     
       rescue StandardError => e
         log_exception(e)
      end
      
    def force_deregister_attached_service(service_query)
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
     return log_error_mesg( 'force_deregister_ no matching service found',service_query) unless service_hash.is_a?(Hash)
     return remove_from_managed_service(service_hash)   
    end
    
    def force_reregister_attached_service(service_query)
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = system_registry_client.find_engine_service_hash(complete_service_query)
      return log_error_mesg( 'force_register no matching service found',service_query) unless service_hash.is_a?(Hash)
      remove_from_managed_service(service_hash) 
      add_to_managed_service(service_hash) 
      rescue StandardError => e
        log_exception(e)
    end


end