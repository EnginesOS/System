# @!group /containers/engine/:engine_name/actions/

# @method get_engine_actions
# @overload get '/v0/containers/engine/:engine_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/engine/:engine_name/actions/' do
  begin
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, params) if engine.nil?
    list = engines_api.list_engine_actionators(engine)
    return_json_array(list)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method get_engine_action
# @overload get '/v0/containers/engine/:engine_name/action/:action_name'
# return engine action
# @return [Hash]

get '/v0/containers/engine/:engine_name/action/:action_name' do
  begin
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, params) if engine.nil?
    action = engines_api.get_engine_actionator(engine, params[:action_name])
    return_json(action)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @method preform_engine_action
# @overload post '/v0/containers/engine/:engine_name/action/:action_name'
# preform engine action
#  post params to include action specific parameters
# @param action specific keys
# @return [Hash] action specific keys
post '/v0/containers/engine/:engine_name/action/:action_name' do
  begin
    p_params = post_params(request)
    p_params[:engine_name] = params[:engine_name]
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, p_params) if engine.nil?
    cparams = assemble_params(p_params, [:engine_name], :all)
    SystemDebug.debug(SystemDebug.actions, 'action', params[:action_name], cparams)
    action = engines_api.perform_engine_action(engine, params[:action_name], cparams)
    SystemDebug.debug(SystemDebug.actions, 'action Res', action)
    return_json(action)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
