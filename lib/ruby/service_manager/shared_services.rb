module SharedServices
  def attach_existing_service_to_engine(shared_service_params)
    r = ''
    existing_service = shared_service_params[ :existing_service]    
    shared_service = shared_service_params.dup
    shared_service.delete(:existing_service)
    shared_service[:service_owner] =  existing_service[:parent_engine]
    shared_service[:service_owner_handle] =  existing_service[:service_handle]
    SystemDebug.debug(SystemDebug.services,'sm using existing service', shared_service_params,existing_service,shared_service)
    service_query = shared_service.dup
    
    service_query[:service_handle] = existing_service[:service_handle]
    service_query[:parent_engine] = existing_service[:parent_engine]
      
    existing_service_hash =  get_service_entry(service_query)
    return log_error_mesg('Failed to find service to share', service_query) unless existing_service_hash.is_a?(Hash)
    SystemDebug.debug(SystemDebug.services,'sm using existing service', existing_service_hash)
    merge_variables(shared_service,existing_service_hash)  
    shared_service[:shared] = true
    shared_service[:service_handle] = shared_service[:parent_engine] + ':' + existing_service[:service_handle]
    shared_service[:container_type] = existing_service[:container_type] 
    shared_service[:container_type] = existing_service[:container_type] 
    shared_service[:service_container_name] = existing_service[:service_container_name]

    SystemDebug.debug(SystemDebug.services,'sm regsitring ', shared_service)
      if shared_service[:type_path] == 'filesystem/local/filesystem'    
        shared_service[:variables][:volume_src] = existing_service[:variables][:volume_src] + '/' +  shared_service[:variables][:volume_src]  
        return r unless (r = attach_shared_volume(shared_service))
       
      end
    shared_service.delete(:existing)
    test_registry_result(system_registry_client.add_share_to_managed_engines_registry(shared_service))
      
  rescue StandardError => e
    log_exception(e,shared_service)
  end
  
  def attach_shared_volume(shared_service)
  engine = @core_api.loadManagedEngine(shared_service[:parent_engine])
    #used by the builder whn no engine to add volume to def
     return engine unless  engine.is_a?(ManagedEngine)
      # Volume.complete_service_hash(shared_service)      
    return true
    rescue StandardError => e
      log_exception(e,shared_service)
  end
  
  def dettach_shared_volume(service_hash)
   engine = @core_api.loadManagedEngine(service_hash[:parent_engine])
     return engine unless engine.is_a?(ManagedEngine)
   
    return test_registry_result(system_registry_client.remove_from_managed_engines_registry(service_hash)) if engine.del_volume(service_hash)
  end
  
  def remove_shared_service_from_engine(service_query)
    r = ''
    ahash = find_engine_service_hash(service_query)
    return ahash unless ahash.is_a?(Hash)
    return log_error_mesg("Not a Shared Service",service_query,ahash) unless ahash[:shared] == true
   # return dettach_shared_volume(ahash) if ahash[:type_path] == 'filesystem/local/filesystem'     
    SystemDebug.debug(SystemDebug.services,  :remove_shared_service_from_engine, ahash)
      return r if (r = system_registry_client.remove_from_managed_engines_registry(ahash)).is_a?(EnginesError)
    SystemDebug.debug(SystemDebug.services,  :remove_shared_service_from_share_reg, ahash)
    return test_registry_result(system_registry_client.remove_from_shares_registry(ahash))
  rescue StandardError => e
    log_exception(e)
  end



  def merge_variables(shared_service,existing_service_hash)
    shared_service[:variables] = {} unless shared_service.key?(:variables)
    existing_service_hash[:variables].each_pair.each do |name, value |
      shared_service[:variables][name] = value unless shared_service[:variables].key?(name)
    end
  rescue StandardError => e
    log_exception(e,shared_service)
  end

end