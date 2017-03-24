# @!group /containers/engine/:engine_name/actions/

# @method get_engine_actions
# @overload get '/v0/containers/engine/:engine_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/engine/:engine_name/actions/' do
  begin
    engine = get_engine(params[:engine_name])
    return_json_array(engines_api.list_engine_actionators(engine))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_engine_action
# @overload get '/v0/containers/engine/:engine_name/action/:action_name'
# return engine action
# @return [Hash]

get '/v0/containers/engine/:engine_name/action/:action_name' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engines_api.get_engine_actionator(engine, params[:action_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
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
    cparams = assemble_params(p_params, [:engine_name], :all)
    return_json(engines_api.perform_engine_action(engine, params[:action_name], cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
