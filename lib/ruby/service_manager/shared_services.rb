module SharedServices
  def attach_existing_service_to_engine(shared_service_params)
    existing_service = shared_service_params[ :existing_service]    
    shared_service = shared_service_params.dup
    shared_service.delete(:existing_service)
    SystemDebug.debug(SystemDebug.services,'sm using existing service', shared_service_params,existing_service,shared_service)
    service_query = shared_service.dup
    
    service_query[:parent_engine] = existing_service[:parent_engine]
    existing_service_hash =  get_service_entry(service_query)
    return log_error_mesg('Failed to find service to share', service_query) unless existing_service_hash.is_a?(Hash)
    SystemDebug.debug(SystemDebug.services,'sm using existing service', existing_service_hash)
    merge_variables(shared_service,existing_service_hash)  
    shared_service[:shared] = true
      
    SystemDebug.debug(SystemDebug.services,'sm regsitring ', shared_service)
    return attach_shared_volume(shared_service) if shared_service[:type_path] == 'filesystem/local/filesystem'     
    test_registry_result(system_registry_client.add_to_managed_engines_registry(shared_service))
  rescue StandardError => e
    log_exception(e,shared_service)
  end
  
  def attach_shared_volume(shared_service)
  engine = @core_api.loadManagedEngine(shared_service[:parent_engine])
    return log_error_mesg("failed to attach share volume parent engine not loaded",shared_service[:parent_engine]) unless engine.is_a?(ManagedEngine)

  return test_registry_result(system_registry_client.add_to_managed_engines_registry(shared_service))  if engine.add_volume(shared_service)
    return false
    rescue StandardError => e
      log_exception(e,shared_service)
  end
  def dettach_shared_volume(service_hash)
   engine = @core_api.loadManagedEngine(service_hash[:parent_engine])
     return log_error_mesg("failed to attach share volume parent engine not loaded",service_hash[:parent_engine]) unless engine.is_a?(ManagedEngine)
   
    return test_registry_result(system_registry_client.remove_from_managed_engines_registry(service_hash)) if engine.del_volume(service_hash)
  end
  
  def remove_shared_service_from_engine(service_query)

    ahash = find_engine_service_hash(service_query)
    return log_error_mesg("Failed to load from registry",service_query) unless ahash.is_a?(Hash)
    return log_error_mesg("Not a Shared Service",service_query,ahash) unless ahash[:shared] == true
    return dettach_shared_volume(ahash) if ahash[:type_path] == 'filesystem/local/filesystem'     
    return test_registry_result(system_registry_client.remove_from_managed_engines_registry(ahash))
      
  rescue StandardError => e
    log_exception(e)
  end

  private

  def merge_variables(shared_service,existing_service_hash)
    shared_service[:variables] = {} unless shared_service.key?(:variables)
    existing_service_hash[:variables].each_pair.each do |name, value |
      shared_service[:variables][name] = value unless shared_service[:variables].key?(name)
    end
  rescue StandardError => e
    log_exception(e,shared_service)
  end

end