module PublicApiContainersPersistentServices
  def create_and_register_persistent_service(service_hash)
    core.create_and_register_service(service_hash)
  end

  def connect_share_service(cparams)
    core.connect_share_service(cparams)
  end

  def connect_orphan_service(cparams)
    core.connect_orphan_service(cparams)
  end

  def update_attached_persistent_service(service_hash)
    core.update_attached_service(service_hash)
  end

  def remove_persistent_service(service_hash)
    core.dettach_service(service_hash)
  end

  def dettach_share_service(cparams)
    core.dettach_share_service(cparams)
  end

  def list_persistent_services(engine)
    core.list_persistent_services(engine)
  end

  def force_deregister_persistent_service
    core.force_deregister_persistent_service(service_hash)
  end

end
