module NonPersistantServices
  require_relative 'service_container_actions.rb'
  def register_non_persistant_service(service_hash)
       ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
       clear_error
      return log_error_mesg('Failed to create persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))
       return true 
       rescue StandardError => e
         log_exception(e)
     end
     
     def force_register_attached_service(service_query)
       p service_query.class.name
       complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
       service_hash = @system_registry.find_engine_service_hash(complete_service_query)
       return log_error_mesg( 'force_reregister no matching service found',service_query) unless service_hash.is_a?(Hash)
       add_to_managed_service(service_hash)     
       rescue StandardError => e
         log_exception(e)
      end
      
    def force_deregister_attached_service(service_query)
      p service_query.class.name
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = @system_registry.find_engine_service_hash(complete_service_query)
     return log_error_mesg( 'force_deregister_ no matching service found',service_query) unless service_hash.is_a?(Hash)
     return remove_from_managed_service(service_hash)   
    end
    
    def force_reregister_attached_service(service_query)
      p service_query.class.name
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = @system_registry.find_engine_service_hash(complete_service_query)
      return log_error_mesg( 'force_register no matching service found',service_query) unless service_hash.is_a?(Hash)
      return add_to_managed_service(service_hash) if remove_from_managed_service(service_hash) 
     return false   
      rescue StandardError => e
        log_exception(e)
    end
    
     def deregister_non_persistant_service(service_hash)
       clear_error
      return log_error_mesg('Failed to create persistant service ',service_hash) unless remove_from_managed_service(service_hash)
       return log_error_mesg('Failed to deregsiter service from managed service registry',service_hash) unless test_registry_result(@system_registry.remove_from_services_registry(service_hash))
       return true   
       rescue StandardError => e
         log_exception(e)
     end
     
   #service manager get non persistant services for engine_name
   #for each servie_hash load_service_container and add hash
   #add to service registry even if container is down
   def register_non_persistant_services(engine)
     clear_error
     params = {}
     params[:parent_engine] = engine.container_name
     params[:container_type] = engine.ctype
     services = get_engine_nonpersistant_services(params)
     p :register_non_persistant_services
     p services.to_s
    return log_error_mesg("No Services for " + params.to_s, services)  unless services.is_a?(Array)
     services.each do |service_hash|
       register_non_persistant_service(service_hash)
     end
     return true   
     rescue StandardError => e
       log_exception(e)
   end
 
   #service manager get non persistant services for engine_name
    #for each servie_hash load_service_container and remove hash
    #remove from service registry even if container is down
    def deregister_non_persistant_services(engine)
      clear_error
      params = {}
      params[:parent_engine] = engine.container_name
      params[:container_type] = engine.ctype
      services = get_engine_nonpersistant_services(params)
      p :deregister_non_persistant_services
         p services.to_s
      return false  unless services.is_a?(Array)
      services.each do |service_hash|
        test_registry_result(@system_registry.remove_from_services_registry(service_hash))
        remove_from_managed_service(service_hash)
      end
      return true   
      rescue StandardError => e
        log_exception(e)
    end
    
  #@return [Array] of all service_hashs marked persistance false for :engine_name
   # required keys
   # :engine_name
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
   def get_engine_nonpersistant_services(params)
     test_registry_result(@system_registry.get_engine_nonpersistant_services(params))
   end
 

end