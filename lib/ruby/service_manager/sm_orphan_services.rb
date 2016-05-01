require_relative 'result_checks.rb'
require_relative 'service_container_actions.rb'
module SmOrphanServices

def orphanate_service(params)
  SystemDebug.debug(SystemDebug.orphans, :Orphanate)
   test_registry_result(system_registry_client.orphanate_service(params))   
  rescue StandardError => e
    log_exception(e)
 end

 ## ????
def release_orphan(params)
  remove_orphaned_service(params)
end

  def rollback_orphaned_service(service_hash)
    test_registry_result(system_registry_client.rollback_orphaned_service(service_hash))   
  end
  
#@returns [Hash] suitable for use  to attach as a service
  #nothing written to the tree
  def reparent_orphan(params)
    test_registry_result(system_registry_client.reparent_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end
 
  
def match_orphan_service(service_hash)
  res =  retrieve_orphan(service_hash)
  return res
end

  def retrieve_orphan(params)
    test_registry_result(system_registry_client.retrieve_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end

  #@ removes underly service and remove entry from orphaned services
  #@returns boolean indicating success
  def remove_orphaned_service(service_query_hash)
    clear_error
    service_hash = retrieve_orphan(service_query_hash)
     if service_query_hash[:remove_all_data] == false
       service_hash[:remove_all_data] = false
     else 
       service_hash[:remove_all_data] = true
     end

    return log_error_mesg('failed to retrieve orphan service:' +  @last_error.to_s,service_hash)  if service_hash.nil? || service_hash == false
    return test_registry_result(system_registry_client.release_orphan(service_hash)) if remove_from_managed_service(service_hash)  
    rescue StandardError => e
      log_exception(e)
  end

  
  #@return an [Array] of service_hashs of Orphaned persistent services matching @params [Hash]
   # required keys
   # :publisher_namespace
   # optional
   #:path_type
   #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
   #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
   def get_orphaned_services(params)
     test_and_lock_registry_result(system_registry_client.get_orphaned_services(params))
   end
  
  end