get '/v0/containers/service/:service_name/metrics/network' do
  r = @@engines_api.get_container_network_metrics(params[:service_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end

get '/v0/containers/service/:service_name/metrics/memory' do
  service = get_service(params[:service_name])
  r = @@engines_api.container_memory_stats(service)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end