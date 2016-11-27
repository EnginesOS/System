module SmEngineServices
  #def find_engine_services(params)
  #  system_registry_client.find_engine_services(params)
  #end
  def find_engine_services_hashes(params)
    clear_error
    test_registry_result(system_registry_client.find_engine_services_hashes(params))
  end
  #
  
  def find_engine_service_hash(params)
    clear_error
    test_registry_result(system_registry_client.find_engine_service_hash(params))
  end

  #@return [Array] of all service_hashs marked persistence true for :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_persistent_services(params)
    test_registry_result(system_registry_client.get_engine_persistent_services(params))
  end

  #@return [Array] of all service_hashs marked persistence false for :engine_name
  # required keys
  # :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_nonpersistent_services(params)
    test_registry_result(system_registry_client.get_engine_nonpersistent_services(params))
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and remove hash
  #remove from service registry even if container is down
  def deregister_non_persistent_services(engine)
    clear_error
    params = {}
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistent_services(params)
    return services  unless services.is_a?(Array)
    services.each do |service_hash|
      test_registry_result(system_registry_client.remove_from_services_registry(service_hash))
      remove_from_managed_service(service_hash)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end
  def list_persistent_services(engine)
      clear_error
      params = {}
  params[:parent_engine] = engine.container_name
  params[:container_type] = engine.ctype

  services = get_engine_persistent_services(params)
return services
    rescue StandardError => e
      log_exception(e)
  end 
  def list_non_persistent_services(engine)
      clear_error
      params = {}
  params[:parent_engine] = engine.container_name
  params[:container_type] = engine.ctype

  services = get_engine_nonpersistent_services(params)

return services
    rescue StandardError => e
      log_exception(e)
  end
  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistent_services(engine)
    clear_error
    params = {}
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistent_services(params)
    return services  unless services.is_a?(Array)
    services.each do |service_hash|
      register_non_persistent_service(service_hash)
      SystemDebug.debug(SystemDebug.services,:register_non_persistent,service_hash)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def remove_engine_from_managed_engines_registry(params)
    r = system_registry_client.remove_from_managed_engines_registry(params)
    return r
  rescue StandardError => e
    log_exception(e)
  end
  
  def get_cron_entry(cronjob, container)

   entry = find_engine_service_hash({:parent_engine => container.container_name,
                                      :publisher_namespace => 'EnginesSystem',
                                      :type_path =>'cron',
                                      :service_handle => cronjob})
   s = {:parent_engine => container.container_name,
                                          :publisher_namespace => 'EnginesSystem',
                                          :type_path =>'cron',
                                          :service_handle => cronjob}
                                          STDERR.puts('serach for ' + s.to_s + ' returned ' + entry)             
         return  entry unless entry.is_a?(Hash)
    entry[:variables][:cron_job]
   
  end

  #@ remove an engine matching :engine_name from the service registry, all non persistent serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistent services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine_services(params)
    clear_error
    services = test_registry_result(system_registry_client.get_engine_persistent_services(params))
    services.each do | service |
      SystemDebug.debug(SystemDebug.services, :remove_service, service)
      if params[:remove_all_data] || service[:shared] #&& ! (service.key?(:shared) && service[:shared])
        service[:remove_all_data] = params[:remove_all_data]
        if (r = delete_service(service)).is_a?(EnginesError)
         return r
        #  next
        end        
      else
        if (r = orphanate_service(service)).is_a?(EnginesError)
          return r
        # next
        end
      end
      system_registry_client.remove_from_managed_engines_registry(service)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

end