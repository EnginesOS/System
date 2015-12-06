module ContainerStates
  
  def get_engines_states
    @core_api.service_manager.get_engines_states
  end
  
  def get_services_states
    @core_api.service_manager.get_services_states
  end
end