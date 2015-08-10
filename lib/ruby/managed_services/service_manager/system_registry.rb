



def test_registry_result(result)
  clear_last_error
  if result == nil
    @last_error=@system_registry.last_error      
  end
  return result
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


def update_service_configuration(config_hash)      
  test_registry_result(@system_registry.update_service_configuration(config_hash))
    end
    
    

