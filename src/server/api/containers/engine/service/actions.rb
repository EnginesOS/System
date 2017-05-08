# @!group /containers/service/:service_name/actions/

# @method get_service_actions
# @overload get '/v0/containers/service/:service_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/service/:service_name/actions/' do
  begin
    service = get_service(params[:service_name])
    return_json_array(services_api.list_service_actionators(service))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_service_action
# @overload get '/v0/containers/service/:service_name/action/:action_name'
# return service action
# @return [Hash]

get '/v0/containers/service/:service_name/action/:action_name' do
  begin
    service = get_service(params[:service_name])
    return_json(services_api.get_service_actionator(service, params[:action_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method preform_service_action
# @overload post '/v0/containers/service/:service_name/action/:action_name'
# preform service action
#  post params to include action specific parameters
# @param action specific keys
# @return [Hash] action specific keys
post '/v0/containers/service/:service_name/action/:action_name' do
  begin
    p_params = post_params(request)
    p_params[:service_name] = params[:service_name]
    service = get_service(params[:service_name])
    cparams = assemble_params(p_params, [:service_name], :all)
    action = services_api.get_service_actionator(service, params[:action_name])
    r = services_api.perform_service_action(service, params[:action_name], cparams)
   return return_json(r) if action[:return_type] == 'json'
     STDERR.puts('action ret ' + r.to_s )
    return_text(r)  
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
