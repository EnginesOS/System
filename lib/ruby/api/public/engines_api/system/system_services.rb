class PublicApi 
  
  
  def list_system_services
    system_api.list_system_services
  end
  
  def system_service_status(sn)
    system_api.loadSystemService(sn).status
  end
  
  def system_service_state(sn)
    system_api.loadSystemService(sn).state
  end

end