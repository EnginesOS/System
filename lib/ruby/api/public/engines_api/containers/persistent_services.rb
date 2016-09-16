module PublicApiContainersPersistentServices
  def create_and_register_persistent_service(cparams)
    @core_api.create_and_register_service(service_hash)
  end

  def connect_share_service(cparams)
    @core_api.connect_orphan_service(cparams)
  end

  def connect_orphan_service(cparams)
    @core_api.connect_orphan_service(cparams)
  end

  def update_attached_persistent_service(service_hash)
    @core_api.update_attached_service(service_hash)
  end

  def remove_persistent_service(cparams)
    @core_api.dettach_service(service_hash)
  end

  def dettach_share_service(cparams)
    @core_api.dettach_share_service(cparams)
  end

  def list_persistent_services(engine)
    @service_manager.list_persistent_services(engine)
  end
end