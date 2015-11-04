module EngineServiceReaders
  
  #def find_engine_services(params)
   #  @system_registry.find_engine_services(params)
   #end
   def find_engine_services_hashes(params)
     clear_error
     test_registry_result(@system_registry.find_engine_services_hashes(params))
   end
   #
   
   def find_engine_service_hash(params)
       clear_error
       test_registry_result(@system_registry.find_engine_service_hash(params))
     end


  #@return [Array] of all service_hashs marked persistance true for :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_persistant_services(params)
    test_registry_result(@system_registry.get_engine_persistant_services(params))
  end
  
  
end