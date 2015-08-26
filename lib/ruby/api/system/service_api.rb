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
  
  def load_and_attach_persistant_services(container)
    dirname = get_container_services_dir(container) + '/pre/'
    service_manager.load_and_attach_services(dirname, container )
  end

  def load_and_attach_shared_services(container)
    dirname = get_container_services_dir(container) + '/shared/'
    service_manager.load_and_attach_services(dirname, container)
  end

  def load_and_attach_nonpersistant_services(container)
    dirname = get_container_services_dir(container) + '/post/'
    service_manager.load_and_attach_services(dirname, container)
  end

  def get_container_services_dir(container)
    @engines_core.container_state_dir(container) + '/services/'
  end

  
end