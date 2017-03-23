# @!group /containers/engine/:engine_name/metrics
# @method get_engine_metrics_network
# @overload get '/v0/containers/engine/:engine_name/metrics/network'
# return engine network usage  :in :out
#
# @return [Hash]
get '/v0/containers/engine/:engine_name/metrics/network' do
  begin
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, params) if engine.nil?
    r = engines_api.get_container_network_metrics(engine)
    return_json(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method get_engine_metrics_memory
# @overload get '/v0/containers/engine/:engine_name/metrics/memory'
# return engine memory usage
#
# @return [Hash]  :maximum :current :limit
get '/v0/containers/engine/:engine_name/metrics/memory' do
  begin
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, params) if engine.nil?
    r = engines_api.container_memory_stats(engine)
    return_json(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
