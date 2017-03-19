# @!group /registry/

# @method get_managed_engine_tree
# @overload get '/v0/registry/engines/'
# Return engines services registry tree
# @return [RubyTree]
get '/v0/registry/engines/' do
  begin
    engines = engines_api.get_managed_engine_tree
    return_json(engines)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_configurations_tree
# @overload get '/v0/registry/configurations/'
# Return configurations  registry tree
# @return [RubyTree]
get '/v0/registry/configurations/' do
  begin
    configurations = engines_api.get_configurations_tree
    return_json(configurations)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_managed_service_tree
# @overload get '/v0/registry/services/'
# Return managed services registry tree
# @return [RubyTree]
get '/v0/registry/services/' do
  begin
    services = engines_api.managed_service_tree
    return_json(services)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_orphan_services_tree
# @overload get '/v0/registry/orphans/'
# Return engines orphan_services registry tree
# @return  [RubyTree]
get '/v0/registry/orphans/' do
  begin
    orphans = engines_api.get_orphaned_services_tree
    return_json(orphans)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_share_services_tree
# @overload get '/v0/registry/shares/'
# Return shared services registry tree
# @return [RubyTree]
get '/v0/registry/shares/' do
  begin
    shares = engines_api.get_shares_tree
    return_json(shares)
  rescue StandardError =>e
    log_error(request, e)
  end
end
