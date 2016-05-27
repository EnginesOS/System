# @!group /containers/service/:service_name/actions/

# @method get_service_actions
# @overload get '/v0/containers/service/:service_name/actions/'
# return a list of the registered actions
# @return [Array]
get '/v0/containers/service/:service_name/actions/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  list = engines_api.list_service_actionators(service)
    unless list.is_a?(EnginesError)
      list.to_json
  else
    return log_error(request, list, service.last_error)
  end
end
# @method get_service_action
# @overload get '/v0/containers/service/:service_name/action/:action_name'
# return service action 
# @return [Hash]

get '/v0/containers/service/:service_name/action/:action_name' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  action = engines_api.get_service_actionator(service, params[:action_name])
    unless action.is_a?(EnginesError) 
      action.to_json
  else
    return log_error(request, action, service.last_error)
  end
end 
# @method preform_service_action
# @overload post '/v0/containers/service/:service_name/action/:action_name'
# preform  service action
#  post params to include action specific parameters
# @return [Hash]
post '/v0/containers/service/:service_name/action/:action_name' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(params, [:service_name], :all)
   action = engines_api.perform_service_action(service, params[:action_name], cparams)
  unless action.is_a?(EnginesError) 
      action.to_json
  else
    return log_error(request, action, service.last_error)
  end
end 
# @!endgroup