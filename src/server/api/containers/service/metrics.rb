# @!group /containers/service/:service_name/metrics
# @method get_service_metrics_network
# @overload get '/v0/containers/service/:service_name/metrics/network'
# return service network usage
#  :in :out
# @return [Hash]
get '/v0/containers/service/:service_name/metrics/network' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = engines_api.get_container_network_metrics(service)
  return log_error(request, r) if r.is_a?(EnginesError)
  return_json(r)
end
# @method get_service_metrics_memory
# @overload get '/v0/containers/service/:service_name/metrics/memory'
# return service memory usage
#   :maximum :current :limit
# @return [Hash]
get '/v0/containers/service/:service_name/metrics/memory' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = engines_api.container_memory_stats(service)
  return log_error(request, r) if r.is_a?(EnginesError)
  return_json(r)
end

# @!endgroup