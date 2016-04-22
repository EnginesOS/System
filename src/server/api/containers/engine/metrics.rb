get '/v0/containers/engine/:engine_name/metrics/network' do
  r = @@core_api.get_container_network_metrics(params[:engine_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(params[:engine_name])
  end
end

get '/v0/containers/engine/:engine_name/metrics/memory' do
  engine = get_engine(params[:engine_name])
    return false if engine.is_a?(FalseClass)
  r = @@core_api.container_memory_stats(engine)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(engine.last_error)
  end
end