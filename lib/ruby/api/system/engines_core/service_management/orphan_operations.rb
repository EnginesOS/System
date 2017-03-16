module OrphanOperations
  require_relative 'service_manager_access.rb'
  #@return an [Array] of service_hashs of Orphaned persistent services match @params [Hash]
  #:path_type :publisher_namespace
  def get_orphaned_services(service_hash)
     check_service_hash(service_hash)
    service_manager.get_orphaned_services(service_hash)
  end

  def remove_orphaned_service(service_hash)
    check_engine_hash(service_hash)
    service_manager.remove_orphaned_service(service_hash)
  end

  def  match_orphan_service(service_hash)
    check_service_hash(service_hash)
    service_manager.match_orphan_service(service_hash)
  end

  def rollback_orphaned_service(service_hash)
    check_engine_hash(service_hash)
    service_manager.rollback_orphaned_service(service_hash)
  end

  def  retrieve_orphan(service_hash)
    check_engine_hash(service_hash)
    service_manager.retrieve_orphan(service_hash)
  end

  def release_orphan(service_hash)
     check_engine_hash(service_hash)
    service_manager.release_orphan(service_hash)
  end
  
  def connect_orphan_service(service_hash)
     check_engine_hash(service_hash)
      service_manager.connect_orphan_service(service_hash)    
  end
  def reparent_orphan(service_hash, engine_name)  
     check_engine_hash(service_hash)
      service_manager.reparent_orphan(service_hash, engine_name)    
  end
end