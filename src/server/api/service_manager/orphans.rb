#/service_manager/orphan_services
#/service_manager/orphan_service/

get '/v0/service_manager/orphan_services' do
  orphans = @@engines_api.get_orphaned_services_tree
unless orphans.is_a?(FalseClass)
  return orphans.to_json
else
  return log_error(request)
end
end

get '/v0/service_manager/orphan_services/:ns/:type_path' do
  r = @@engines_api.retrieve_service_hash(service_hash)
unless r.is_a?(FalseClass)
  return r.to_json
else
  return log_error(request)
end
end

delete '/v0/service_manager/orphan_services/:ns/:type_path/:service_handle' do
  service_hash = service_hash_from_params(params)
  r = @@engines_api.remove_orphaned_service(service_hash)
 
unless r.is_a?(FalseClass)
  return r.to_json
else
  return log_error(request)
end
end