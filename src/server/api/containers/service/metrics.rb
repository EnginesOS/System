get '/v0/containers/service/:service_name/metrics/network' do
  r = @@core_api.get_container_network_metrics(params[:service_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end

get '/v0/containers/service/:service_name/metrics/memory' do
  service = get_service(params[:service_name])
  r = @@core_api.container_memory_stats(service)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end