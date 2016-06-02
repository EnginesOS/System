# @!group /containers/engine/:engine_name/actions/

# @method get_engine_actions
# @overload get '/v0/containers/engine/:engine_name/actions/'
# return an of the registered action Hashes
# @return [Array] Hash
get '/v0/containers/engine/:engine_name/actions/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  list = engines_api.list_engine_actionators(engine)
    unless list.is_a?(EnginesError)
      list.to_json
  else
    return log_error(request, list, engine.last_error)
  end
end

# @method get_engine_action
# @overload get '/v0/containers/engine/:engine_name/action/:action_name'
# return engine action 
# @return [Hash] 

get '/v0/containers/engine/:engine_name/action/:action_name' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
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
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
   
  cparams =  Utils::Params.assemble_params(params, [:engine_name], :all)
   action = engines_api.perform_engine_action(engine, params[:action_name], cparams)
  unless action.is_a?(EnginesError) 
      action.to_json
  else
    return log_error(request, action, engine.last_error)
  end
end 