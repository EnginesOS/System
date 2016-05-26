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

  params[:type_path] = params['splat'][0] if params.key?('splat') && params['splat'].is_a?(Array)

  cparams =  Utils::Params.assemble_params(params, [:publisher_namespace, :type_path], [])

  r = engines_api.get_orphaned_services(cparams)
unless r.is_a?(EnginesError)
  return r.to_json
else
  return log_error(request, r)
end
end

get '/v0/service_manager/orphan_service/:publisher_namespace/*' do
pparams = Utils::ServiceHash.service_hash_from_params(params, false)
p pparams
      splats = params['splat']
      hash[:type_path] = File.dirname(splats[0])
      hash[:service_handle] = File.basename(hash[:type_path])
      hash[:type_path] = File.dirname(hash[:type_path])
      hash[:parent_engine] = File.basename(splats[0])

cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], []) 
r = engines_api.retrieve_orphan(cparams)

unless r.is_a?(EnginesError)
return r.to_json
else
return log_error(request, r)
end
end

delete '/v0/service_manager/orphan_service/:publisher_namespace/*' do
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
