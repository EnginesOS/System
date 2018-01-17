module SMSubservices
  def services_subservices(params)
    @subservices_registry.services_subservices(params)
  end

  def update_subservice(params)
    @subservices_registry.update_subservice(params)
  end

  def attach_subservice(params)
    @subservices_registry.attach_subservice(params)
  end

  def remove_subservice(params)
    @subservices_registry.remove_subservice(params)
  end

  def attached_subservice(params)
    @subservices_registry.attached_subservice(params)
  end

  def subservice_provided(params)
    @subservices_registry.subservice_provided(params)
  end

  def subservices_provided(params)
    @subservices_registry.subservices_provided(params)
  end

end