module PublicApiOrphans
  
  def retrieve_orphans
    @core_api.match_orphan_service(service_hash)    
  end
  
  def retrieve_orphan
    @core_api.retrieve_orphan(service_hash)
  end
  
  
  def remove_orphaned_service(service_hash)
    @core_api.remove_orphaned_service(service_hash)
  end
end