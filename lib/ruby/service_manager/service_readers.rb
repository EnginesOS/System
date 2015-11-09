module ServiceReaders
  
  ###READERS

  #list the Provider namespaces as an Array of Strings
  #@return [Array]
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def list_providers_in_use
    test_and_lock_registry_result(@system_registry.list_providers_in_use)
  end



  #Test whether a service hash is registered
  #@return's false on failure with error (if applicable) accessible from this object's  [ServiceManager] last_error method
  def service_is_registered?(service_hash)
    test_registry_result(@system_registry.service_is_registered?(service_hash))  
    rescue StandardError => e
      log_exception(e)
  end

  def all_engines_registered_to(service_type)
   test_registry_result(@system_registry.all_engines_registered_to(service_type))  
        rescue StandardError => e
          log_exception(e)
  end
  
  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    clear_error
    test_registry_result(@system_registry.get_registered_against_service(params))   
    rescue StandardError => e
      log_exception(e)
  end

  def get_service_entry(service_hash)
     test_registry_result(@system_registry.get_service_entry(service_hash))
   end
  
  
end