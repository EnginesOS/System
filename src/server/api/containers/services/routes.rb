
get '/v0/containers/services/' do
  engines = @@engines_api.getManagedServices
  unless engines.is_a?(EnginesError)
    return engines.to_json
  else
    return log_error(request,engines )
  end
end

get '/v0/containers/services/container_name' do
  container_names = @@engines_api.list_managed_services
  unless container_names.is_a?(EnginesError)
    return container_names.to_json
  else
    return log_error(request, container_names)
  end
end

get '/v0/containers/services/state' do
  states = @@engines_api.get_services_states
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end
get '/v0/containers/services/system' do
  states = @@engines_api.list_system_services
  unless states.is_a?(EnginesError)
    return states.to_json
  else
    return log_error(request, states)
  end
end
