# @!group /containers/engine/:engine_name/actions/

# @method get_engine_actions
# @overload get '/v0/containers/engine/:engine_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/engine/:engine_name/actions/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  list = engines_api.list_engine_actionators(engine)
    unless list.is_a?(EnginesError)
      list.to_json
  else
    return log_error(request, list)
  end
end

# @method get_engine_action
# @overload get '/v0/containers/engine/:engine_name/action/:action_name'
# return engine action 
# @return [Hash] 

get '/v0/containers/engine/:engine_name/action/:action_name' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  action = engines_api.get_engine_actionator(engine, params[:action_name])
    unless action.is_a?(EnginesError) 
      action.to_json
  else
    return log_error(request, action, engine.last_error)
  end
end 

# @method preform_engine_action
# @overload post '/v0/containers/engine/:engine_name/action/:action_name'
# preform engine action
#  post params to include action specific parameters
# @param action specific keys
# @return [Hash] action specific keys
post '/v0/containers/engine/:engine_name/action/:action_name' do
  p_params = post_params(request)
  engine = get_engine(p_params[:engine_name])
  return log_error(request, engine, p_params) if engine.is_a?(EnginesError)
   
  cparams =  Utils::Params.assemble_params(p_params, [:engine_name], :all)
   action = engines_api.perform_engine_action(engine, p_params[:action_name], cparams)
  unless action.is_a?(EnginesError) 
      action.to_json
  else
    return log_error(request, action, engine.last_error)
  end
end 