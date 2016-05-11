#/containers/engines/state

#/containers/engines/container_name
#/containers/engines/
#/containers/engine/container_name/build_report
#/containers/engine/container_name/blueprint

get '/v0/containers/engine/:engine_name' do
  engine = get_engine(params[:engine_name])
  unless engine.is_a?(EnginesError)
    return engine.to_json
  else
    return log_error(request,engine, params[:engine_name])
  end
end

get '/v0/containers/engine/:engine_name/state' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.read_state
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/blueprint' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.load_blueprint
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
get '/v0/containers/engine/:engine_name/build_report' do
  r = engines_api.get_build_report(params[:engine_name])
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
