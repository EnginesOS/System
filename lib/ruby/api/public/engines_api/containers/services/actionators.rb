module PublicApiServiceActionators
  def list_service_actionators(service)
    @system_api.list_service_actionators(service)
  end

  def get_service_actionator(engine, action)
    @system_api.get_engine_actionator(engine, action)
  end

  def perform_service_action(service_name,actionator_name,params)
    @core_api.perform_service_action(service_name,actionator_name,params)
  end

end 