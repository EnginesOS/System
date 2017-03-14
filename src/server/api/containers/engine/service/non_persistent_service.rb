# @!group /containers/engine/:engine_name/service/non_persistent/

# @method update_engine_non_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle'
# update non persistent services in the :publisher_namespace :type_path and service_handle registered to the engine with posted params
# post api_vars :variables  Note attempts to change service_handle will fail
# @return [true|false]

post '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*' do
  p_params = post_params(request)
   path_hash = engine_service_hash_from_params(params, false)
   p_params.merge!(path_hash)
   cparams = assemble_params(p_params, [:parent_engine,:publisher_namespace, :type_path, :service_handle], :all)
   return log_error(request,cparams,p_params) if cparams.is_a?(EnginesError)
 
  r = engines_api.update_attached_service(cparams)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end

# @method engine_force_register_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/register'
# force register the non persistent service
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/register' do

  hash = engine_service_hash_from_params(params)
  service_hash =  engines_api.find_engine_service_hash(hash)
  return log_error(request, service_hash, hash)  if service_hash.is_a?(EnginesError)
  r = engines_api.force_register_attached_service(service_hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)

end
# @method engine_force_reregister_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/reregister'
# force reregister the non persistent service
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/reregister' do

  hash = engine_service_hash_from_params(params)
  service_hash =  engines_api.find_engine_service_hash(hash)
  return log_error(request, service_hash, hash) if service_hash.is_a?(EnginesError)
  r = engines_api.force_reregister_attached_service(service_hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end
# @method engine_force_deregister_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/deregister'
# force deregister the non persistent service
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/deregister' do

  hash = engine_service_hash_from_params(params)
  service_hash =  engines_api.find_engine_service_hash(hash)
  return log_error(request, service_hash, hash) if service_hash.is_a?(EnginesError)
  r = engines_api.force_deregister_attached_service(service_hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end

# @method engine_get_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  @return [Hash]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*' do
  hash = engine_service_hash_from_params(params)
  r = engines_api.find_engine_service_hash(hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_json(r)
end
# @!endgroup