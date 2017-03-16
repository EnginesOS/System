module PublicApiContainersPersistentServices
  def create_and_register_persistent_service(service_hash)
    @core_api.create_and_register_service(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def connect_share_service(cparams)
    @core_api.connect_share_service(cparams)
  rescue StandardError => e
    handle_exception(e)
  end

  def connect_orphan_service(cparams)
    @core_api.connect_orphan_service(cparams)
  rescue StandardError => e
    handle_exception(e)
  end

  def update_attached_persistent_service(service_hash)
    @core_api.update_attached_service(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_persistent_service(service_hash)
    @core_api.dettach_service(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def dettach_share_service(cparams)
    @core_api.dettach_share_service(cparams)
  rescue StandardError => e
    handle_exception(e)
  end

  def list_persistent_services(engine)
    @core_api.list_persistent_services(engine)
  rescue StandardError => e
    handle_exception(e)
  end
end