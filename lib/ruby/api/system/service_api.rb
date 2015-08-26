class ServiceApi < ContainerApi
  
  def get_registered_against_service(params)
    @engines_core.get_registered_against_service(params)
  end
  
  def service_manager
    @engines_core.service_manager
  end
  
  def load_and_attach_persistant_services(service)
    @engines_core.load_and_attach_persistant_services(service)
  end 
  
  def load_and_attach_shared_services(service)
    @engines_core.load_and_attach_shared_services(service)
  end

  
end