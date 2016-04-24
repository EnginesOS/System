get '/v0/containers/engine/:engine_name/metrics/network' do
  engine = get_engine(params[:engine_name])
  r = @@engines_api.get_container_network_metrics(engine)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end

get '/v0/containers/engine/:engine_name/metrics/memory' do
  engine = get_engine(params[:engine_name])
    return false if engine.is_a?(FalseClass)
  r = @@engines_api.container_memory_stats(engine)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, engine.last_error)
  end
end