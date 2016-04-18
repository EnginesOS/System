#/containers/engines/state
#/containers/engines/container_name
#/containers/engines/


get '/v0/containers/engines/' do
  engines = @@core_api.getManagedEngines
  unless engines.is_a?(FalseClass)
    return engines.to_json
  else
    return log_error('engines')
  end
end


get '/v0/containers/engines/container_name' do
  container_names = @@core_api.list_managed_engines
  unless container_names.is_a?(FalseClass)
    return container_names.to_json
  else
    return log_error('container_name')
  end
end

get '/v0/containers/engines/state' do
  states = @@core_api.get_engines_states
  unless states.is_a?(FalseClass)
    return states.to_json
  else
    return log_error('states')
  end
end