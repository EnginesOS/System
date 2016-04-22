#/registry/containers/engines
#/registry/configurations
#/registry/engines/services
#/registry/services/services
#/registry/orphans
#/registry/shares

get '/v0/registry/engines/' do
  engines = @@core_api.get_managed_engine_tree
  unless engines.is_a?(FalseClass)
    return engines.to_json
  else
    return log_error('get_managed_engine_tree')
  end
end

get '/v0/registry/configurations/' do
  configurations = @@core_api.get_configurations_tree
  unless configurations.is_a?(FalseClass)
    return configurations.to_json
  else
    return log_error('configurations tree')
  end
end

get '/v0/registry/services/' do
  services = @@core_api.managed_service_tree
  unless services.is_a?(FalseClass)
    return services.to_json
  else
    return log_error('services/ tree' )
  end
end

get '/v0/registry/orphans/' do
  orphans = @@core_api.get_orphaned_services_tree
unless orphans.is_a?(FalseClass)
  return orphans.to_json
else
  return log_error('orphans trdd')
end
end
  get '/v0/registry/shares/' do
    shares = @@core_api.get_shares_tree
    unless shares.is_a?(FalseClass)
      return shares.to_json
    else
      return log_error('shares tree ')
    end
  end
