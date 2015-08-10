def test_registry_result(result)
  clear_last_error
  if result == nil
    @last_error=@system_registry.last_error      
  end
  return result
end

def get_orphaned_services(params)    
  test_registry_result(@system_registry.get_orphaned_services(params))
end
def orphan_service(params)      
  test_registry_result(@system_registry.orphan_service(params))
end

def retrieve_orphan(params)      
  test_registry_result(@system_registry.retrieve_orphan(params))
end
def release_orphan(params)      
  test_registry_result(@system_registry.release_orphan(params))
  end
def reparent_orphan(params)      
  test_registry_result(@system_registry.reparent_orphan(params))
 end
def get_orphaned_services_tree      
  test_registry_result(@system_registry.orphaned_services_registry)
end
def get_engine_nonpersistant_services(params)      
  test_registry_result(@system_registry.get_engine_nonpersistant_services(params))
end
def get_engine_persistant_services(params)      
  test_registry_result(@system_registry.get_engine_persistant_services(params))
    end
def managed_service_tree
  test_registry_result(@system_registry.services_registry)      
end
def get_managed_engine_tree      
  test_registry_result(@system_registry.managed_engines_registry)
 end
def service_configurations_tree      
  test_registry_result(@system_registry.service_configurations_registry)
end
def service_is_registered?(service_hash)      
  test_registry_result(@system_registry.service_is_registered?(service_hash))
end

def get_service_configurations_hashes(service_hash)      
  test_registry_result(@system_registry.get_service_configurations_hashes(service_hash))
  end
    
def update_service_configuration(config_hash)      
  test_registry_result(@system_registry.update_service_configuration(config_hash))
    end
    
    
#list the Provider namespaces as an Array of Strings
#@return [Array]
def list_providers_in_use
  test_registry_result(@system_registry.list_providers_in_use)

end
