get '/v0/containers/engine/:id/metrics/network' do
  r = @@core_api.get_container_network_metrics(params[:id])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end

get '/v0/containers/engine/:id/metrics/memory' do
  engine = get_engine(params[:id])
  r = @@core_api.container_memory_stats(engine)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end