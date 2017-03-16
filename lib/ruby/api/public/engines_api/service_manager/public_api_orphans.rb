module PublicApiOrphans
  def get_orphaned_services(service_hash)
    @core_api.get_orphaned_services(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def retrieve_orphan(service_hash)
    @core_api.retrieve_orphan(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_orphaned_service(service_hash)
    @core_api.remove_orphaned_service(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end
end