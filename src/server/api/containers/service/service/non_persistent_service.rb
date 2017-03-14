# @!group /containers/service/:service_name/service/non_persistent/

# @method service_force_register_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/register'
# force register the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/register' do

  hash = service_service_hash_from_params(params)

  service_hash = engines_api.find_service_service_hash(hash)
  return log_error(request, 'Service not found', hash) if service_hash.is_a?(EnginesError)
  r = engines_api.force_register_attached_service(service_hash)

  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end
# @method service_force_reregister_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/reregister'
# force reregister the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/reregister' do

  hash = service_service_hash_from_params(params)
  service_hash = engines_api.find_service_service_hash(hash)
  return service_hash if service_hash.is_a?(EnginesError)
  r = engines_api.force_reregister_attached_service(service_hash)

  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end
# @method service_force_deregister_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/deregister'
# force deregister the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/deregister' do

  hash = service_service_hash_from_params(params)
  service_hash = engines_api.find_service_service_hash(hash)
  return service_hash  if service_hash.is_a?(EnginesError)
  r = engines_api.force_deregister_attached_service(service_hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end
# @method service_get_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  @return [Hash]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*' do
  #splats = params['splat']

  hash = service_service_hash_from_params(params)
  r = engines_api.find_service_service_hash(hash) #find_engine_services_hashes(hash)
  return log_error(request, 'service not found', r, hash) if r.is_a?(EnginesError)
  return_json(r)
end

#
#get '/v0/containers/service/:service_name/service/non_persistent/' do
#  service = get_service(params[:service_name])
#  r = engines_api.list_non_persistent_services(service)
#
#  unless r.is_a?(FalseClass)
#    return r.to_json
#  else
#    return log_error('pause')
#  end
#end

# @!endgroup