require_relative 'result_checks.rb'
module OrphanServices

def orphanate_service(params)
   test_registry_result(@system_registry.orphanate_service(params))   
  rescue StandardError => e
    log_exception(e)
 end

def release_orphan(params)
  test_registry_result(@system_registry.release_orphan(params))   
  rescue StandardError => e
    log_exception(e)
end

  
#@returns [Hash] suitable for use  to attach as a service
  #nothing written to the tree
  def reparent_orphan(params)
    test_registry_result(@system_registry.reparent_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end
 
  
def match_orphan_service(service_hash)
  res =  retrieve_orphan(service_hash)
  return true if res.is_a?(Hash)
  return false
end

  def retrieve_orphan(params)
    test_registry_result(@system_registry.retrieve_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end
  
  end