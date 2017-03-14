# @!group /containers/engines/
# @method get_engines
# @overload  get '/v0/containers/engines/'
# @return [Array]  of Engines [Hash] 
get '/v0/containers/engines/' do
  engines = engines_api.getManagedEngines
  return log_error(request, engines) if engines.is_a?(EnginesError)
  managed_containers_to_json(engines)  
end
# @method get_engines_container_name
# @overload get '/v0/containers/engines/container_name'
# returns an array of the container_name of configured engines
# @return [Array] of container_names [String]
#
get '/v0/containers/engines/container_name' do
  container_names = engines_api.list_managed_engines
  return log_error(request, container_names) if container_names.is_a?(EnginesError)
  return_json_array(container_names)  
end
# @method get_engines_status
# @overload get '/v0/containers/engines/status'
# returns a [container_name => engines_status,] of the container_name of configured engines
# @return [Array] Status Hash with keys :container_name values Hash with keys :state :set_state :progress_to :error
get '/v0/containers/engines/status' do 
  status = engines_api.get_engines_status
  return log_error(request, states) if status.is_a?(EnginesError)
  return_json(status)
end
# @method get_engines_state
# @overload get '/v0/containers/engines/state'
# returns a [container_name =>engines_state,] of the container_name of configured engines
# @return [Hash] States :container_name running|stopped|paused|nocontainer
get '/v0/containers/engines/state' do 
  states = engines_api.get_engines_states
  return log_error(request, states) if  states.is_a?(EnginesError)
  return_json(states)
end
# @!endgroup