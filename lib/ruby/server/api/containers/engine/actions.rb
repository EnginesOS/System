get '/v0/containers/engine/:id/actions/' do
  engine = get_engine(params[:id])
  return false if engine.is_a?(FalseClass)
  list = @@core_api.list_engine_actionators(engine)
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error('add_domain', params)
  end
end

get '/v0/containers/engine/:id/action/:action_id' do
  engine = get_engine(params[:id])
  return false if engine.is_a?(FalseClass)
  action = @@core_api.get_engine_actionator(engine, params[:action_id])
    unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('remove_domain')
  end
end 

post '/v0/containers/engine/:id/action/:action_id' do
  engine = get_engine(params[:id])
   return false if engine.is_a?(FalseClass)
   action = @@core_api.perform_engine_action(engine, params[:action_id], Utils.symbolize_keys(params))
  unless action.is_a?(FalseClass) 
      action.to_json
  else
    return log_error('remove_domain')
  end
end 