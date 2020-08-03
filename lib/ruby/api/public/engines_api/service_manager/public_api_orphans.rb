class PublicApi 
  def orphaned_services(service_hash)
    core.orphaned_services(service_hash)
  end

  def retrieve_orphan(service_hash)
    core.retrieve_orphan(service_hash)
  end

  def remove_orphaned_service(service_hash)
    core.remove_orphaned_service(service_hash)
    true
  end

  def orphan_lost_services
    core.orphan_lost_services
  end
end
