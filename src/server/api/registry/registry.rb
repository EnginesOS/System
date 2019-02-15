# @!group /registry/

# @method get_managed_engine_tree
# @overload get '/v0/registry/engines/'
# Return engines services registry tree
# @return [RubyTree]
get '/v0/registry/engines/' do
  begin
    return_json(engines_api.managed_engines_registry)
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
    return_json(engines_api.service_configurations_registry)
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
    return_json(engines_api.managed_services_registry)
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
    return_json(engines_api.orphaned_services_registry)
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
    return_json(engines_api.shared_services_registry)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_subservices_services_tree
# @overload get '/v0/registry/subservices/'
# Return subservices registry tree
# @return [RubyTree]
get '/v0/registry/subservices/' do
  begin
    return_json(engines_api.subservices_registry)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end