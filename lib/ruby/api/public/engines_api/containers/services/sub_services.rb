module PublicApiSubServices
  def services_subservices(params)
    @core_api.services_subservices(params)
  end

  def update_subservice(params)
    @core_api.update_subservice(params)
  end

  def attach_subservice(params)
    @core_api.attach_subservice(params)
  end

  def remove_subservice(params)
    @core_api.remove_subservice(params)
  end

  def attached_subservice(params)
    @core_api.attached_subservice(params)
  end

  def subservice_provided(params)
    @core_api.subservice_provided(params)
  end

  def subservices_provided(params)
    @core_api.subservices_provided(params)
  end

end