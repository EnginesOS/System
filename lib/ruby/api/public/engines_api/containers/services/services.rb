module PublicApiServices
  def getManagedServices
    @system_api.getManagedServices
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
    
  end
  
end