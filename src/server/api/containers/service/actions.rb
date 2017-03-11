# @!group /containers/service/:service_name/actions/

# @method get_service_actions
# @overload get '/v0/containers/service/:service_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/service/:service_name/actions/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  list = engines_api.list_service_actionators(service)
  return log_error(request, list, service.last_error) if list.is_a?(EnginesError)
return_json_array(list)
end
# @method get_service_action
# @overload get '/v0/containers/service/:service_name/action/:action_name'
# return service action
# @return [Hash]

get '/v0/containers/service/:service_name/action/:action_name' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  action = engines_api.get_service_actionator(service, params[:action_name])
  return log_error(request, action, service.last_error) if action.is_a?(EnginesError)
  return_json(action)

end
# @method preform_service_action
# @overload post '/v0/containers/service/:service_name/action/:action_name'
# preform service action
#  post params to include action specific parameters
# @param action specific keys
# @return [Hash] action specific keys
post '/v0/containers/service/:service_name/action/:action_name' do
  p_params = post_params(request)
  service = get_service(p_params[:service_name])
  return log_error(request, service, p_params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(p_params, [:service_name], :all)
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  action = engines_api.perform_service_action(service, p_params[:action_name], cparams)
  return log_error(request, action, service.last_error) if action.is_a?(EnginesError)
  return_json(action)
end
# @!endgroup