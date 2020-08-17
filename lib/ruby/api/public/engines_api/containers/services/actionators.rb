class PublicApi 
  def list_service_actionators(c)
    system_api.load_service_actionators(c)
  end

  def get_service_actionator(service, action)
    system_api.get_service_actionator(service, action)
  end

  def perform_service_action(service_name, actionator, params)
    core.perform_service_action(service_name, actionator, params)
  end
  
  def perform_service_stream_action(service_name, actionator, params, out)
    params[:std_stream] = out
    core.perform_service_action(service_name, actionator, params, out)
  end
end
