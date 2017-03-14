# @!group /containers/engine/:engine_name/metrics
# @method get_engine_metrics_network
# @overload get '/v0/containers/engine/:engine_name/metrics/network'
# return engine network usage  :in :out
#
# @return [Hash]
get '/v0/containers/engine/:engine_name/metrics/network' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.get_container_network_metrics(engine)
  return log_error(request, r) if r.is_a?(EnginesError)
  return_json(r)
end
# @method get_engine_metrics_memory
# @overload get '/v0/containers/engine/:engine_name/metrics/memory'
# return engine memory usage
#
# @return [Hash]  :maximum :current :limit
get '/v0/containers/engine/:engine_name/metrics/memory' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.container_memory_stats(engine)
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_json(r)
end