#/containers/engines/state

#/containers/engines/container_name
#/containers/engines/
#/containers/engine/container_name/build_report
#/containers/engine/container_name/blueprint

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
 return false if engine.is_a?(FalseClass)
  r = engine.read_state
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('engine')
  end
end

get '/v0/containers/engine/:id/blueprint' do
  engine = get_engine(params[:id])
  return false if engine.is_a?(FalseClass)
  r = engine.load_blueprint
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('blueprint')
  end
end
get '/v0/containers/engine/:id/build_report' do
  r = @@core_api.get_build_report(params[:id])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('build_report')
  end
end
