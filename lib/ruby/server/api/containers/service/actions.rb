get '/v0/containers/service/:id/actions/' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  list = @@core_api.list_service_actionators(service)
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error('service actions', params)
  end
end

get '/v0/containers/service/:id/action/:action_id' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  action = @@core_api.get_service_actionator(service, params[:action_id])
    unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('remove_domain')
  end
end 

post '/v0/containers/service/:id/action/:action_id' do
  service = get_service(params[:id])
   return false if service.is_a?(FalseClass)
   action = @@core_api.perform_service_action(service, params[:action_id], Utils.symbolize_keys(params))
  unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('remove_domain')
  end
end 