module ContainerStates
  def get_engines_states
    @system_api.get_engines_states
  end

  def get_services_states
    @system_api.get_services_states
  end
  
 def init_container_info_dir(params)
  @system_api.init_container_info_dir(params)
     
end

  def user_clear_error(container)
    container.user_clear_error
  end
end