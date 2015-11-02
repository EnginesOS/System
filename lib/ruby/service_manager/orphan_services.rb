require_relative 'result_checks.rb'
module OrphanServices

def orphanate_service(params)
  p :Orphanate
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

  
  #@return an [Array] of service_hashs of Orphaned persistant services matching @params [Hash]
   # required keys
   # :publisher_namespace
   # optional
   #:path_type
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
   def get_orphaned_services(params)
     test_and_lock_registry_result(@system_registry.get_orphaned_services(params))
   end
  
  end