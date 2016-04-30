get '/v0/containers/engine/:engine_name/actions/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  list = @@engines_api.list_engine_actionators(engine)
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error(request, list, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/action/:action_name' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  action = @@engines_api.get_engine_actionator(engine, params[:action_name])
    unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error(request, action, engine.last_error)
  end
end 

post '/v0/containers/engine/:engine_name/action/:action_name' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
   
  cparams =  Utils::Params.assemble_params(params, [:engine_name], :all)
   action = @@engines_api.perform_engine_action(engine, params[:action_name], cparams)
  unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error(request, action, engine.last_error)
  end
end 