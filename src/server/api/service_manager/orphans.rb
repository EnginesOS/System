# @!group /service_manager/orphan_services/

# @method get_all_orphan_services
# @overload get '/v0/service_manager/orphan_services/'
# @return [Array] Orphan Service Hashes
get '/v0/service_manager/orphan_services/' do
  orphans = engines_api.get_orphaned_services_tree
  return log_error(request, orphans) if orphans.is_a?(EnginesError)
  orphans.to_json
end
# @method get_orphan_services_by_type
# @overload get '/v0/service_manager/orphan_services/:publisher_namespace/:type_path:'
# @return [Array] Orphan Service Hashes
get '/v0/service_manager/orphan_services/:publisher_namespace/*' do
  params[:type_path] = params['splat'][0] if params.key?('splat') && params['splat'].is_a?(Array)
  cparams =  Utils::Params.assemble_params(params, [:publisher_namespace, :type_path], [])
return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.get_orphaned_services(cparams)
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end
# @method get_orphan_service
# @overload get '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# @return [Hash] Orphan Service Hash
get '/v0/service_manager/orphan_service/:publisher_namespace/*' do

  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = File.dirname(splats[0])
  pparams[:service_handle] = File.basename(pparams[:type_path])
  pparams[:type_path] = File.dirname(pparams[:type_path])
  pparams[:parent_engine] = File.basename(splats[0])

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.retrieve_orphan(cparams)

  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end
# @method delete_orphan_service
# @overload delete '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# remove underlying data and delete orphan
# @return [true]
delete '/v0/service_manager/orphan_service/:publisher_namespace/*' do
  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = File.dirname(splats[0])
  pparams[:service_handle] = File.basename(pparams[:type_path])
  pparams[:type_path] = File.dirname(pparams[:type_path])
  pparams[:parent_engine] = File.basename(splats[0])

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  service_hash = engines_api.retrieve_orphan(cparams)
  STDERR.puts('Orphan restrived to DELETE ' + service_hash.to_s  + ' From ' + cparams.to_s)
  return service_hash if service_hash.is_a?(EnginesError)

  r = engines_api.remove_orphaned_service(service_hash)

  return log_error(request, r) if r.is_a?(EnginesError)
content_type 'text/plain' 
  r.to_s
end
# @!endgroup
