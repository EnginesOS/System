
get '/v0/containers/services/' do
  engines = @@core_api.getManagedServices
  unless engines.is_a?(FalseClass)
    return engines.to_json
  else
    return log_error('services')
  end
end

get '/v0/containers/services/container_name' do
  container_names = @@core_api.list_managed_services
  unless container_names.is_a?(FalseClass)
    return container_names.to_json
  else
    return log_error('container_name')
  end
end

get '/v0/containers/services/state' do
  states = @@core_api.get_services_states
  unless states.is_a?(FalseClass)
    return states.to_json
  else
    return log_error('states')
  end
end