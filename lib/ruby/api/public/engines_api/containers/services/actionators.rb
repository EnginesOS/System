module PublicApiServiceActionators
  def list_service_actionators(service)
    @system_api.load_service_actionators(service)
  end

  def get_service_actionator(service, action)
    @system_api.get_service_actionator(service, action)
  end

  def perform_service_action(service_name, actionator, params)
    @core_api.perform_service_action(service_name, actionator, params)
  end

end 