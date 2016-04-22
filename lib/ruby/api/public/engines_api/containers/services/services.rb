module Services
  def getManagedServices
    @system_api.getManagedServices
  end

  def  list_managed_services
    @system_api.list_managed_services
  end

  def  get_services_states
    @system_api.get_services_states
  end

  def list_system_services
    @system_api.list_system_services
  end

end