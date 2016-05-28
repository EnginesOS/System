# @!group /containers/engines/
# @method get_engines
# @overload  get '/v0/containers/engines/'
# @return [Array]  Engines [Hash] 
get '/v0/containers/engines/' do
  engines = engines_api.getManagedEngines
  unless engines.is_a?(EnginesError)
    return engines.to_json
  else
    return log_error(request, engines)
  end
end
# @method get_engines_container_name
# @overload get '/v0/containers/engines/container_name'
# returns an array of the container_name of configured engines
# @return [Array] container_names
#
get '/v0/containers/engines/container_name' do
  container_names = engines_api.list_managed_engines
  unless container_names.is_a?(EnginesError)
    return container_names.to_json
  else
    return log_error(request, container_names)
  end
end
# @method get_engines_status
# @overload get '/v0/containers/engines/status'
# returns a [container_name => engines_status,] of the container_name of configured engines
# @return [Array] Status :container_name Hashs  :state :set_state :progress_to :error
get '/v0/containers/engines/status' do 
  status = engines_api.get_engines_status
  unless status.is_a?(EnginesError)
    return status.to_json
  else
    return log_error(request, states)
  end
end
# @method get_engines_state
# @overload get '/v0/containers/engines/state'
# returns a [container_name =>engines_state,] of the container_name of configured engines
# @return [Hash] States :container_name running|stopped|paused|nocontainer
get '/v0/containers/engines/state' do 
  states = engines_api.get_engines_states
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end
# @!endgroup