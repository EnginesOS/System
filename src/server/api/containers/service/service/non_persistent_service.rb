# @!group /containers/service/:service_name/service/non_persistent/

# @method service_force_register_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/register'
# force register the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/register' do
  begin
    hash = service_service_hash_from_params(params)
    service_hash = engines_api.find_service_service_hash(hash)
    r = engines_api.force_register_attached_service(service_hash)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method service_force_reregister_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/reregister'
# force reregister the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/reregister' do
  begin
    hash = service_service_hash_from_params(params)
    service_hash = engines_api.find_service_service_hash(hash)
    r = engines_api.force_reregister_attached_service(service_hash)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method service_force_deregister_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/deregister'
# force deregister the non persistent service
# @return [true|false]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*/deregister' do
  begin
    hash = service_service_hash_from_params(params)
    service_hash = engines_api.find_service_service_hash(hash)
    r = engines_api.force_deregister_attached_service(service_hash)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method service_get_non_persistent_service
# @overload get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  @return [Hash]
get '/v0/containers/service/:service_name/service/non_persistent/:publisher_namespace/*' do
  begin
    hash = service_service_hash_from_params(params)
    r = engines_api.find_service_service_hash(hash) #find_engine_services_hashes(hash)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup