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

end