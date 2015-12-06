module ContainerStates
  
  def get_engines_states
    service_manager.get_engines_states
  end
  
  def get_services_states
    service_manager.get_services_states
  end
end
