# @!group /containers/engine/:engine_name/service/non_persistent/


# @method engine_force_register_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/register' 
# force register the non persistent service  
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/register' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  
 service_hash =  engines_api.find_engine_service_hash(hash)
  return service_hash  if service_hash.is_a?(EnginesError)
  r = engines_api.force_register_attached_service(service_hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end
# @method engine_force_reregister_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/reregister' 
# force reregister the non persistent service  
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/reregister' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  
 service_hash =  engines_api.find_engine_service_hash(hash)
  return service_hash if service_hash.is_a?(EnginesError)
  r = engines_api.force_reregister_attached_service(service_hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end
# @method engine_force_deregister_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle/deregister'
# force deregister the non persistent service  
# @return [true|false]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*/deregister' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  
 service_hash =  engines_api.find_engine_service_hash(hash)
  return service_hash if service_hash.is_a?(EnginesError)
 r = engines_api.force_deregister_attached_service(service_hash)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end

# @method engine_get_non_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  @return [Hash]
get '/v0/containers/engine/:engine_name/service/non_persistent/:publisher_namespace/*' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  
 
  r = engines_api.find_engine_service_hash(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, hash)
  end
end
# @!endgroup