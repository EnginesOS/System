# @!group /service_manager/service_definitions/

get '/v0/service_manager/orphan_services/' do
  orphans = engines_api.get_orphaned_services_tree
unless orphans.is_a?(EnginesError)
  return orphans.to_json
else
  return log_error(request, orphans)
end
end

get '/v0/service_manager/orphan_services/:publisher_namespace/*' do
p params
  params[:type_path] = params['splat'][0] if params.key?('splat') && params['splat'].is_a?(Array)
p params  
  cparams =  Utils::Params.assemble_params(params, [:publisher_namespace, :type_path], []) 
  r = engines_api.retrieve_orphans(cparams)
unless r.is_a?(EnginesError)
  return r.to_json
else
  return log_error(request, r)
end
end

get '/v0/service_manager/orphan_service/:publisher_namespace/:type_path/*' do
pparams = Utils::Params.service_hash_from_params(params, false)
cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle], []) 
r = engines_api.retrieve_orphan(cparams)

unless r.is_a?(EnginesError)
return r.to_json
else
return log_error(request, r)
end
end

delete '/v0/service_manager/orphan_service/:publisher_namespace/:type_path/*' do
  pparams = Utils::Params.service_hash_from_params(params, false)
  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle], []) 
  service_hash = engines_api.retrieve_orphan(cparams)
  return service_hash if service_hash.is_a?(EnginesError)
  r = engines_api.remove_orphaned_service(service_hash)
 
unless r.is_a?(EnginesError)
  return r.to_json
else
  return log_error(request, r)
end
end
# @!endgroup
