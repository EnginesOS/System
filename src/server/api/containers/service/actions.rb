get '/v0/containers/service/:service_name/actions/' do
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
  list = @@core_api.list_service_actionators(service)
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error('service actions', params)
  end
end

get '/v0/containers/service/:service_name/action/:action_name' do
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
  action = @@core_api.get_service_actionator(service, params[:action_name])
    unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('action')
  end
end 

post '/v0/containers/service/:service_name/action/:action_name' do
  service = get_service(params[:service_name])
   return false if service.is_a?(FalseClass)
  cparams =  Utils::Params.assemble_params(params, [:service_name], :all)
   action = @@core_api.perform_service_action(service, params[:action_name], cparams)
  unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('action')
  end
end 