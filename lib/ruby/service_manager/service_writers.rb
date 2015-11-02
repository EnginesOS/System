module ServiceWriters
  

  #@ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  #@ All are added to the ManagesEngine/Service Tree
  #@ return true if successful or false if failed
  def add_service(service_hash)
    clear_error
    service_hash[:variables][:parent_engine] = service_hash[:parent_engine] unless service_hash[:variables].has_key?(:parent_engine)
    ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
    test_registry_result(@system_registry.add_to_managed_engines_registry(service_hash))
    return true if service_hash.key?(:shared) && service_hash[:shared] == true
    if ServiceDefinitions.is_service_persistant?(service_hash)
      return log_error_mesg('Failed to create persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))
    else
      return log_error_mesg('Failed to create non persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))
    end
    return true
  rescue Exception=>e
    puts e.message
    log_exception(e)
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def delete_service(service_query)
    clear_error
    complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
    service_hash = @system_registry.find_engine_service_hash(complete_service_query)
    return log_error_mesg('Failed to match params to registered service',service_hash) unless service_hash
    service_hash[:remove_all_data] = service_query[:remove_all_data]
    return log_error_mesg('failed to remove from managed service',service_hash) unless remove_from_managed_service(service_hash) || service_query[:force].key?
    return log_error_mesg('failed to remove managed service from services registry', service_hash) unless test_registry_result(@system_registry.remove_from_services_registry(service_hash))
      return true    
  rescue StandardError => e
    log_exception(e)
  end

  def update_attached_service(params)
    clear_error
    ServiceDefinitions.set_top_level_service_params(params,params[:parent_engine])
    if test_registry_result(@system_registry.update_attached_service(params))
      return add_to_managed_service(params) if remove_from_managed_service(params)
      # this calls add_to_managed_service(params) plus adds to reg
      @last_error='Filed to remove ' + @system_registry.last_error.to_s
    else
      @last_error = @system_registry.last_error.to_s
    end
    return false
  rescue StandardError => e
    log_exception(e)
  end

  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine_services(params)
    p :REMOVE_engine_services
    clear_error
    p params
    services = test_registry_result(@system_registry.get_engine_persistant_services(params))
    p :persistant_services_FOR_REMOVAL
    p services
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
      @system_registry.remove_from_managed_engines_registry(service)
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end


  def update_service_configuration(config_hash)
    #load service definition and from configurators definition and if saveable save
    service_definition = ServiceDefinitions.software_service_definition(config_hash)
    return log_error_mesg('Missing Service definition file ', config_hash.to_s)  unless service_definition.is_a?(Hash)
    return log_error_mesg('Missing Configurators in service definition', config_hash.to_s) unless service_definition.key?(:configurators)
    configurators = service_definition[:configurators]
    return log_error_mesg('Missing Configurator ', config_hash[:configurator_name]) unless configurators.key?(config_hash[:configurator_name].to_sym)
    configurator_definition = configurators[config_hash[:configurator_name].to_sym]
    unless configurator_definition.key?(:no_save) && configurator_definition[:no_save]
      return test_registry_result(@system_registry.update_service_configuration(config_hash))
    else
      return true
    end
  rescue Exception=>e
    log_exception(e)
  end

  def remove_engine_from_managed_engines_registry(params)
    r = @system_registry.remove_from_managed_engines_registry(params)
    return r
  rescue StandardError => e
    log_exception(e)
  end
end