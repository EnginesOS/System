get '/v0/containers/engine/:engine_name/metrics/network' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.get_container_network_metrics(engine)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/containers/engine/:engine_name/metrics/memory' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)

  r = engines_api.container_memory_stats(engine)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end