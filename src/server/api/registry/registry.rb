# @!group /registry/

# @method get_managed_engine_tree
# @overload get '/v0/registry/engines/'
# Return engines services registry tree
# @return [RubyTree]
get '/v0/registry/engines/' do
  begin
    engines = engines_api.managed_engines_registry
    return_json(engines)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_configurations_tree
# @overload get '/v0/registry/configurations/'
# Return configurations registry tree
# @return [RubyTree]
get '/v0/registry/configurations/' do
  begin
    configurations = engines_api.service_configurations_registry
    return_json(configurations)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_managed_service_tree
# @overload get '/v0/registry/services/'
# Return managed services registry tree
# @return [RubyTree]
get '/v0/registry/services/' do
  begin
    services = engines_api.managed_services_registry
    return_json(services)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_orphan_services_tree
# @overload get '/v0/registry/orphans/'
# Return engines orphan_services registry tree
# @return  [RubyTree]
get '/v0/registry/orphans/' do
  begin
    orphans = engines_api.orphaned_services_registry
    return_json(orphans)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_share_services_tree
# @overload get '/v0/registry/shares/'
# Return shared services registry tree
# @return [RubyTree]
get '/v0/registry/shares/' do
  begin
    shares = engines_api.shared_services_registry
    return_json(shares)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
