module PublicApiContainersNonPersistentServices
  def force_register_attached_service(service_hash)
    @core_api.force_register_non_persistent_service(service_hash)
  end

  def force_reregister_attached_service(service_hash)
    @core_api.force_reregister_non_persistent_service(service_hash)
  end

  def force_deregister_attached_service(service_hash)
    @core_api.force_deregister_non_persistent_service(service_hash)
  end

  def list_non_persistent_services(engine)
    @core_api.list_non_persistent_services(engine)
  end

  def create_and_register_service(service_hash)
    @core_api.create_and_register_service(service_hash)
  end

  def dettach_service(service_hash)
    @core_api.dettach_service(service_hash)
  end

  def update_attached_service(service_hash)
    @core_api.update_attached_service(service_hash)
  end

end