# @!group /service_manager/orphan_services/

# @method get_orphan_services
# @overload get '/v0/service_manager/orphan_services/'
# @return Json Array|EnginesError.to_json
get '/v0/service_manager/orphan_services/' do
  orphans = engines_api.get_orphaned_services
  unless orphans.is_a?(EnginesError)
    return orphans.to_json
  else
    return log_error(request, orphans)
  end
end
# @method get_orphan_services
# @overload get '/v0/service_manager/orphan_services/:publisher_namespace/:type_path:'
# @return Json Array|EnginesError.to_json
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
# @method get_orphan_service
# @overload get '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# @return Json|EnginesError.to_json
get '/v0/service_manager/orphan_service/:publisher_namespace/*' do
 
  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = File.dirname(splats[0])
  pparams[:service_handle] = File.basename(pparams[:type_path])
  pparams[:type_path] = File.dirname(pparams[:type_path])
  pparams[:parent_engine] = File.basename(splats[0])

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
  r = engines_api.retrieve_orphan(cparams)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @method delete_orphan_service
# @overload delete '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# @return true|EnginesError.to_json
delete '/v0/service_manager/orphan_service/:publisher_namespace/*' do
  splats = params['splat']
   pparams =  {}
   pparams[:publisher_namespace] = params[:publisher_namespace]
   pparams[:type_path] = File.dirname(splats[0])
   pparams[:service_handle] = File.basename(pparams[:type_path])
   pparams[:type_path] = File.dirname(pparams[:type_path])
   pparams[:parent_engine] = File.basename(splats[0])
   cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
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
