#/containers/engines/state


#/containers/engines/container_name
#/containers/engines/


get '/v0/containers/engine/:id' do
  engine = get_engine(params[:id])
  unless engine.is_a?(FalseClass)
    return engine.to_json
  else
    return log_error('engine')
  end
end

get '/v0/containers/engine/:id/state' do
  engine = get_engine(params[:id])
  r = engine.read_state
    unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('engine')
  end
end
