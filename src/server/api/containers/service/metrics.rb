get '/v0/containers/service/:service_name/metrics/network' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = @@engines_api.get_container_network_metrics(service)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/containers/service/:service_name/metrics/memory' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = @@engines_api.container_memory_stats(service)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r)
  end
end