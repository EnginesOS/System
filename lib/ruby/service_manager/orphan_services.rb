require_relative 'result_checks.rb'
module OrphanServices

def orphanate_service(params)
   test_registry_result(@system_registry.orphanate_service(params))   
  rescue StandardError => e
    log_exception(e)
 end

 ## ????
def release_orphan(params)
  remove_orphaned_service(params)
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

  #@ removes underly service and remove entry from orphaned services
  #@returns boolean indicating success
  def remove_orphaned_service(service_query_hash)
    clear_error
    service_hash = retrieve_orphan(service_query_hash)
    return log_error_mesg('failed to retrieve orphan service:' +  @last_error.to_s,service_hash)  if service_hash.nil? || service_hash == false
    return test_registry_result(@system_registry.release_orphan(service_hash))   
    rescue StandardError => e
      log_exception(e)
  end

  
  end