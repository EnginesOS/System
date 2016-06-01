
# @!group /registry/

# @method get_managed_engine_tree
# @overload get '/v0/registry/engines/'
# Return engines services registry tree
# @return [RubyTree]
get '/v0/registry/engines/' do
  engines = engines_api.get_managed_engine_tree
  unless engines.is_a?(EnginesError)
    return engines.to_json
  else
    return log_error(request, engines)
  end
end
# @method get_configurations_tree
# @overload get '/v0/registry/configurations/'
# Return configurations  registry tree
# @return [RubyTree]
get '/v0/registry/configurations/' do
  configurations = engines_api.get_configurations_tree
  unless configurations.is_a?(EnginesError)
    return configurations.to_json
  else
    return log_error(request, configurations)
  end
end
# @method get_managed_service_tree
# @overload get '/v0/registry/services/'
# Return managed services registry tree
# @return [RubyTree]
get '/v0/registry/services/' do
  services = engines_api.managed_service_tree
  unless services.is_a?(EnginesError)
    return services.to_json
  else
    return log_error(request, services)
  end
end
# @method get_orphan_services_tree
# @overload get '/v0/registry/orphans/'
# Return engines orphan_services registry tree
# @return  [RubyTree]
get '/v0/registry/orphans/' do
  orphans = engines_api.get_orphaned_services_tree
unless orphans.is_a?(EnginesError)
  return orphans.to_json
else
  return log_error(request, orphans)
end
end
# @method get_share_services_tree
# @overload get '/v0/registry/shares/'
# Return shared services registry tree
# @return [RubyTree]
  get '/v0/registry/shares/' do
    shares = engines_api.get_shares_tree
    unless shares.is_a?(EnginesError)
      return shares.to_json
    else
      return log_error(request, shares)
    end
  end
