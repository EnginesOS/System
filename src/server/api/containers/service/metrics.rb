# @!group /containers/service/:service_name/metrics
# @method get_service_metrics_network
# @overload get '/v0/containers/service/:service_name/metrics/network'
# return service network usage
#  :in :out 
# @return [Hash|EnginesError]
get '/v0/containers/service/:service_name/metrics/network' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = engines_api.get_container_network_metrics(service)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @method get_service_metrics_memory
# @overload get '/v0/containers/service/:service_name/metrics/memory'
# return service memory usage
#    :maximum :current :limit
# @return [Hash|EnginesError]
get '/v0/containers/service/:service_name/metrics/memory' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = engines_api.container_memory_stats(service)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

# @!endgroup