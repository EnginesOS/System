module SharedServices
  def attach_existing_service_to_engine(service_query)

    service_hash =  get_service_entry(service_query)
    return log_error_mesg('Failed to find service to share', service_query) if service_hash.nil?
    SystemDebug.debug(SystemDebug.services,'sm using existing service', service_hash)
    merge_variables(service_query,service_hash)  if service_query.key?(:variables)
    service_hash[:shared] = true
    SystemDebug.debug(SystemDebug.services,'sm regsitring ', service_hash)
    return test_registry_result(system_registry_client.add_to_managed_engines_registry(service_hash))
  rescue StandardError => e
    log_exception(e)
  end

  def remove_shared_service_from_engine(service_query)

    ahash = getfrom_engine_service_resgistry(service_query)
    return log_error_mesg("Failed to load from registry",service_query) unless ahash.is_a?(Hash)
    return log_error_mesg("Not a Shared Service",service_query,ahash) unless ahash[:shared] == true
    return test_registry_result(system_registry_client.remove_from_managed_engines_registry(ahash))
  rescue StandardError => e
    log_exception(e)
  end

  private

  def merge_variables(service_query,service_hash)
    service_query[:variables].each_pair.each do |name, value |
      service_hash[:variables][name] = value
    end
  end

end