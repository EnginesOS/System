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

  #@return [Array] of all service_hashs marked persistance true for :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_persistent_services(params)
    test_registry_result(system_registry_client.get_engine_persistent_services(params))
  end

  #@return [Array] of all service_hashs marked persistance false for :engine_name
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
    #  p :deregister_non_persistent_services
    #     p services.to_s
    return false  unless services.is_a?(Array)
    services.each do |service_hash|
      test_registry_result(system_registry_client.remove_from_services_registry(service_hash))
      remove_from_managed_service(service_hash)
    end
    return true
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
    #  p :register_non_persistent_services
    #   p services.to_s
    return log_error_mesg("No Services for " + params.to_s, services)  unless services.is_a?(Array)
    services.each do |service_hash|
      register_non_persistent_service(service_hash)
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

  #@ remove an engine matching :engine_name from the service registry, all non persistent serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistent services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine_services(params)
    #   p :REMOVE_engine_services
    clear_error
    #    p params
    services = test_registry_result(system_registry_client.get_engine_persistent_services(params))
    #   p :persistent_services_FOR_REMOVAL
    #   p services
    services.each do | service |
      if params[:remove_all_data] && ! (service.key?(:shared) && service[:shared])
        service[:remove_all_data] = params[:remove_all_data]
        unless delete_service(service)
          log_error_mesg('Failed to remove service ',service)
          next
        end
      else
        unless orphanate_service(service)
          log_error_mesg('Failed to orphan service ',service)
          next
        end
      end
      system_registry_client.remove_from_managed_engines_registry(service)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

end