#/containers/engines/state

#/containers/engines/container_name
#/containers/engines/
#/containers/engine/container_name/build_report
#/containers/engine/container_name/blueprint

get '/v0/containers/engine/:engine_name' do
  engine = get_engine(params[:engine_name])
  unless engine.is_a?(FalseClass)
    return engine.to_json
  else
    return log_error(params[:engine_name])
  end
end

get '/v0/containers/engine/:engine_name/state' do
  engine = get_engine(params[:engine_name])
 return false if engine.is_a?(FalseClass)
  r = engine.read_state
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/blueprint' do
  engine = get_engine(params[:engine_name])
  return false if engine.is_a?(FalseClass)
  r = engine.load_blueprint
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(engine.last_error)
  end
end
get '/v0/containers/engine/:engine_name/build_report' do
  r = @@core_api.get_build_report(params[:engine_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('no build_report')
  end
end
