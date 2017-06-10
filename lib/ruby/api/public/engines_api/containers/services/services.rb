module PublicApiServices
  def getManagedServices
    @system_api.getManagedServices
  end

  def getSystemServices
    @system_api.getSystemServices
  end

  def  list_managed_services
    @system_api.list_managed_services
  end

  def  get_services_states
    @system_api.get_services_states
  end

  def  get_services_status
    @system_api.get_services_status
  end

  def list_system_services
    @system_api.list_system_services
  end

  def remove_service(service)
 # STDERR.puts(' REMOVE SERVICE ' + service.to_s + ' Does NOTHING PUBLIC API ' + caller[0..10].to_s)  
  end

end