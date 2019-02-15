module SMSubservices
  #WAS @subservices_registry.
  def services_subservices(params)
    system_registry_client.services_subservices(params)
  end

  def update_subservice(params)
    system_registry_client.update_subservice(params)
  end

  def attach_subservice(params)
    system_registry_client.attach_subservice(params)
  end

  def remove_subservice(params)
    system_registry_client.remove_subservice(params)
  end

  def attached_subservice(params)
    system_registry_client.attached_subservice(params)
  end

  def subservice_provided(params)
    system_registry_client.subservice_provided(params)
  end

  def subservices_provided(params)
    system_registry_client.subservices_provided(params)
  end

end