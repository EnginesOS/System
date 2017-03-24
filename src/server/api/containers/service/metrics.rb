# @!group /containers/service/:service_name/metrics
# @method get_service_metrics_network
# @overload get '/v0/containers/service/:service_name/metrics/network'
# return service network usage
#  :in :out
# @return [Hash]
get '/v0/containers/service/:service_name/metrics/network' do
  begin
    service = get_service(params[:service_name])
    return_json(engines_api.get_container_network_metrics(service))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_service_metrics_memory
# @overload get '/v0/containers/service/:service_name/metrics/memory'
# return service memory usage
#   :maximum :current :limit
# @return [Hash]
get '/v0/containers/service/:service_name/metrics/memory' do
  begin
    service = get_service(params[:service_name])
    return_json(engines_api.container_memory_stats(service))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup