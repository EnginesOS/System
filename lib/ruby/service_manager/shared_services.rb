module SharedServices
  def attach_existing_service_to_engine(shared_service)
  service_query = shared_service.dup
    service_query[:parent_engine] = shared_service[:service_container_name]
    existing_service_hash =  get_service_entry(service_query)
    return log_error_mesg('Failed to find service to share', shared_service) unless existing_service_hash.is_a?(Hash)
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
  engine = loadManagedEngine(shared_service[:parent_engine])
    return log_error_mesg("failed to attach share volume parent engine not loaded",shared_service[:parent_engine]) unless engine.is_a?(ManagedEngine)

  return test_registry_result(system_registry_client.add_to_managed_engines_registry(shared_service))  if engine.add_volume(shared_service)
    return false
    rescue StandardError => e
      log_exception(e,shared_service)
  end
    
  def remove_shared_service_from_engine(service_query)

    ahash = get_from_engine_service_registry(service_query)
    return log_error_mesg("Failed to load from registry",service_query) unless ahash.is_a?(Hash)
    return log_error_mesg("Not a Shared Service",service_query,ahash) unless ahash[:shared] == true
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