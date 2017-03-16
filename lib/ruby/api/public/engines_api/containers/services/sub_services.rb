module PublicApiSubServices
  def services_subservices(params)
    @core_api.services_subservices(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def update_subservice(params)
    @core_api.update_subservice(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def attach_subservice(params)
    @core_api.attach_subservice(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_subservice(params)
    @core_api.remove_subservice(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def attached_subservice(params)
    @core_api.attached_subservice(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def subservice_provided(params)
    @core_api.subservice_provided(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def subservices_provided(params)
    @core_api.subservices_provided(params)
  rescue StandardError => e
    handle_exception(e)
  end

end