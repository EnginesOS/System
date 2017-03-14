
# @!group /registry/

# @method get_managed_engine_tree
# @overload get '/v0/registry/engines/'
# Return engines services registry tree
# @return [RubyTree]
get '/v0/registry/engines/' do
  engines = engines_api.get_managed_engine_tree
  return log_error(request, engines) if engines.is_a?(EnginesError)
  return_json(engines)
end
# @method get_configurations_tree
# @overload get '/v0/registry/configurations/'
# Return configurations  registry tree
# @return [RubyTree]
get '/v0/registry/configurations/' do
  configurations = engines_api.get_configurations_tree
  return log_error(request, configurations) if  configurations.is_a?(EnginesError)
  return_json(configurations)
end
# @method get_managed_service_tree
# @overload get '/v0/registry/services/'
# Return managed services registry tree
# @return [RubyTree]
get '/v0/registry/services/' do
  services = engines_api.managed_service_tree
  return log_error(request, services) if services.is_a?(EnginesError)
  return_json(services)
end
# @method get_orphan_services_tree
# @overload get '/v0/registry/orphans/'
# Return engines orphan_services registry tree
# @return  [RubyTree]
get '/v0/registry/orphans/' do
  orphans = engines_api.get_orphaned_services_tree
  return log_error(request, orphans) if  orphans.is_a?(EnginesError)
  return_json(orphans)
end
# @method get_share_services_tree
# @overload get '/v0/registry/shares/'
# Return shared services registry tree
# @return [RubyTree]
  get '/v0/registry/shares/' do
    shares = engines_api.get_shares_tree
    return log_error(request, shares) if shares.is_a?(EnginesError)
    return_json(shares)
  end
