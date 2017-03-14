module SmEngineServices
  #def find_engine_services(params)
  #  system_registry_client.find_engine_services(params)
  #end
  def find_engine_services_hashes(params)
    clear_error
    system_registry_client.find_engine_services_hashes(params)
  rescue StandardError => e
    handle_exception(e)
  end
  #

  def find_engine_service_hash(params)
    clear_error
    system_registry_client.find_engine_service_hash(params)
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Array] of all service_hashs marked persistence true for :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_persistent_services(params)
    system_registry_client.get_engine_persistent_services(params)
  rescue StandardError => e
    handle_exception(e)
  end

  #@return [Array] of all service_hashs marked persistence false for :engine_name
  # required keys
  # :engine_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_engine_nonpersistent_services(params)
    system_registry_client.get_engine_nonpersistent_services(params)
  rescue StandardError => e
    handle_exception(e)
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and remove hash
  #remove from service registry even if container is down
  def deregister_non_persistent_services(engine)
    clear_error
    params = {
      parent_engine: engine.container_name,
      container_type: engine.ctype
    }
    services = get_engine_nonpersistent_services(params)
    return services  unless services.is_a?(Array)
    services.each do |service_hash|
      system_registry_client.remove_from_services_registry(service_hash)
      remove_from_managed_service(service_hash)
    end
    true
  rescue StandardError => e
    handle_exception(e)
  end

  def list_persistent_services(engine)
    clear_error
    params = {
      parent_engine: engine.container_name,
      container_type: engine.ctype
    }
    services = get_engine_persistent_services(params)
    services
  rescue StandardError => e
    handle_exception(e)
  end

  def list_non_persistent_services(engine)
    clear_error
    params = {
      parent_engine: engine.container_name,
      container_type: engine.ctype
    }
    get_engine_nonpersistent_services(params)
  rescue StandardError => e
    handle_exception(e)
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistent_services(engine)
    clear_error
    params = {
      parent_engine: engine.container_name,
      container_type: engine.ctype
    }
    services = get_engine_nonpersistent_services(params)
    SystemDebug.debug(SystemDebug.services,:register_non_persistent, services)
    return services  unless services.is_a?(Array)
    services.each do |service_hash|
      register_non_persistent_service(service_hash)
      SystemDebug.debug(SystemDebug.services,:register_non_persistent,service_hash)
    end
    true
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_engine_from_managed_engine(params)
    system_registry_client.remove_from_managed_engines_registry(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_cron_entry(cronjob, container)
    entry = find_engine_service_hash({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'cron',
      container_type: container.ctype,
      container_name: container.container_name,
      service_handle:  cronjob})

    return  entry unless entry.is_a?(Hash)
    entry[:variables][:cron_job]

  rescue StandardError => e
    handle_exception(e)
  end

  #@ remove an engine matching :engine_name from the service registry, all non persistent serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistent services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine_services(params)
    clear_error
    r = ''
    services = system_registry_client.get_engine_persistent_services(params)
    STDERR.puts('RM SERVICES ' + params.to_s )
    return true unless services.is_a?(Array)
    services.each do | service |
      SystemDebug.debug(SystemDebug.services, :remove_service, service)
      if params[:remove_all_data] || service[:shared] #&& ! (service.key?(:shared) && service[:shared])
        service[:remove_all_data] = params[:remove_all_data]
        return r  if (r = delete_service(service)).is_a?(EnginesError)
      else
        return r if (r = orphanate_service(service)).is_a?(EnginesError)
      end
      return r if (r = remove_from_managed_engines_registry(service)).is_a?(EnginesError)
    end
    true

  rescue StandardError => e
    handle_exception(e)
  end

end