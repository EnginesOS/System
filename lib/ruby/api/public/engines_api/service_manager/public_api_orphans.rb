module PublicApiOrphans
  def orphaned_services(service_hash)
    @core_api.orphaned_services(service_hash)
  end

  def retrieve_orphan(service_hash)
    @core_api.retrieve_orphan(service_hash)
  end

  def remove_orphaned_service(service_hash)
    @core_api.remove_orphaned_service(service_hash)
  end
  
  def orphan_lost_services
    @core_api.orphan_lost_services
  end
end