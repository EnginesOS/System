module SharedServices
  require_relative 'private/shared_volumes.rb'
  def share_service_to_engine(shared_service_params)
    STDERR.puts( 'share_service_to_engine ' + shared_service_params.to_s)
    existing_service = shared_service_params[ :existing_service]
    shared_service = shared_service_params.dup
    shared_service.delete(:existing_service)
    shared_service[:service_owner] = existing_service[:parent_engine]
    shared_service[:service_owner_handle] = existing_service[:service_handle]
    SystemDebug.debug(SystemDebug.services,'sm using existing service', shared_service_params,existing_service,shared_service)
    service_query = shared_service.dup

    service_query[:service_handle] = existing_service[:service_handle]
    service_query[:parent_engine] = existing_service[:parent_engine]

    existing_service_hash =  get_service_entry(service_query)

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
      attach_shared_volume(shared_service)
    end
    shared_service.delete(:existing)
    system_registry_client.add_share_to_managed_engines_registry(shared_service)
  end

  def remove_shared_service_from_engine(service_query)
    ahash = find_engine_service_hash(service_query)
    return ahash unless ahash.is_a?(Hash)
    raise EnginesException.new(error_hash('Not a Shared Service",service_query,ahash')) unless ahash[:shared] == true
    # return dettach_shared_volume(ahash) if ahash[:type_path] == 'filesystem/local/filesystem'
    SystemDebug.debug(SystemDebug.services,  :remove_shared_service_from_engine, ahash)
    system_registry_client.remove_from_managed_engine(ahash)
    SystemDebug.debug(SystemDebug.services,  :remove_shared_service_from_share_reg, ahash)
    system_registry_client.remove_from_shared_services_registry(ahash)
  end

  def merge_variables(shared_service, existing_service_hash)
    shared_service[:variables] = {} unless shared_service.key?(:variables)
    existing_service_hash[:variables].each_pair.each do |name, value |
      shared_service[:variables][name] = value unless shared_service[:variables].key?(name)
    end
  end

end