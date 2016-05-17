
# @!group Services


# @method get_services
# @overload  get '/v0/containers/services/'
# returns a Json array of the services
# @return [Array] 
get '/v0/containers/services/' do
  engines = engines_api.getManagedServices
  unless engines.is_a?(EnginesError)
    return engines.to_json
  else
    return log_error(request,engines )
  end
end

#
# @method get_services_container_name
# @overload get '/v0/containers/services/container_name'
# returns an array of the container_name of configured services
# @return [Array]
#
get '/v0/containers/services/container_name' do
  container_names = engines_api.list_managed_services
  unless container_names.is_a?(EnginesError)
    return container_names.to_json
  else
    return log_error(request, container_names)
  end
end

# @method get_services_state
# @overload get '/v0/containers/services/state'
# returns a [container_name => service_state,] of the container_name of configured services
# @return [Hash] 

get '/v0/containers/services/state' do
  states = engines_api.get_services_states
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end
get '/v0/containers/services/status' do
  status = engines_api.get_services_status
  unless status.is_a?(EnginesError)
    return status.to_json
  else
    return log_error(request, statuses)
  end
end
# @method get_system_services
# @overload  get '/v0/containers/services/system'
# returns a Json array of the system services
# @return [Array] 
get '/v0/containers/services/system' do
  states = engines_api.list_system_services
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end
# @!endgroup