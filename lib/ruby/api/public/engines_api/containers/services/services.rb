module PublicApiServices
  def getManagedServices
    @system_api.getManagedServices
  rescue StandardError => e
    handle_exception(e)
  end

  def getSystemServices
    @system_api.getSystemServices
  rescue StandardError => e
    handle_exception(e)
  end

  def  list_managed_services
    @system_api.list_managed_services
  rescue StandardError => e
    handle_exception(e)
  end

  def  get_services_states
    @system_api.get_services_states
  rescue StandardError => e
    handle_exception(e)
  end

  def  get_services_status
    @system_api.get_services_status
  rescue StandardError => e
    handle_exception(e)
  end

  def list_system_services
    @system_api.list_system_services
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_service(service)

  end

end