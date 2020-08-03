class PublicApi 
  def  set_container_network_properties(container, params)
    system_api.set_engine_network_properties(container, params)
  end

  def set_container_runtime_properties(container, params)
    core.set_container_runtime_properties(container, params)
  end

end
