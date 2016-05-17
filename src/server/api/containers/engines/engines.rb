#/containers/engines/state
#/containers/engines/container_name
#/containers/engines/

get '/v0/containers/engines/' do
  engines = engines_api.getManagedEngines
  unless engines.is_a?(EnginesError)
    return engines.to_json
  else
    return log_error(request, engines)
  end
end

get '/v0/containers/engines/container_name' do
  container_names = engines_api.list_managed_engines
  unless container_names.is_a?(EnginesError)
    return container_names.to_json
  else
    return log_error(request, container_names)
  end
end
get '/v0/containers/engines/status' do
 
  status = engines_api.get_engines_status
  unless status.is_a?(EnginesError)
    return status.to_json
  else
    return log_error(request, states)
  end
end
get '/v0/containers/engines/state' do
 
  states = engines_api.get_engines_states
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end