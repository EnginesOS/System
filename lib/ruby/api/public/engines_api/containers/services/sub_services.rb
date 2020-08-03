class PublicApi 
  def services_subservices(params)
    core.services_subservices(params)
  end

  def update_subservice(params)
    core.update_subservice(params)
  end

  def attach_subservice(params)
    core.attach_subservice(params)
  end

  def remove_subservice(params)
    core.remove_subservice(params)
  end

  def attached_subservice(params)
    core.attached_subservice(params)
  end

  def subservice_provided(params)
    core.subservice_provided(params)
  end

  def subservices_provided(params)
    core.subservices_provided(params)
  end

end
