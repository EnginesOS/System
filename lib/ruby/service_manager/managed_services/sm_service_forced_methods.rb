require_relative 'private/service_container_actions.rb'
module SmServiceForcedMethods

  def register_non_persistent_service(service_hash)
    service_hash = set_top_level_service_params(service_hash, service_hash[:parent_engine])
    add_to_managed_service(service_hash)
    system_registry_client.add_to_services_registry(service_hash)
  end

  def deregister_non_persistent_service(service_hash)
    service_hash = set_top_level_service_params(service_hash, service_hash[:parent_engine])
    remove_from_managed_service(service_hash)
    system_registry_client.remove_from_services_registry(service_hash)
  end

  def force_register_non_persistent_service(service_query)
    STDERR.puts('Service query ' + service_query.to_s)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
    service_hash = retrieve_engine_service_hash(complete_service_query)
    STDERR.puts('found Service hash ' + service_query.to_s)
    add_to_managed_service(service_hash)
  end

  def force_deregister_non_persistent_service(service_query)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
    service_hash = retrieve_engine_service_hash(complete_service_query)
    remove_from_managed_service(service_hash)
  end

  def force_reregister_non_persistent_service(service_query)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
    service_hash = retrieve_engine_service_hash(complete_service_query)
    remove_from_managed_service(service_hash)
    add_to_managed_service(service_hash)
  end

end