module PublicApiContainersProperties
  def  set_container_network_properties(container, params)
    @system_api.set_engine_network_properties(container,params)
  rescue StandardError => e
    handle_exception(e)
  end

  def set_container_runtime_properties(container, params)
    @core_api.set_container_runtime_properties(container, params)
  rescue StandardError => e
    handle_exception(e)
  end

end