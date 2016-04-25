
get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/register' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  

  r = @@engines_api.force_register_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end

get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/reregister' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
 
  r = @@engines_api.force_reregister_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end

get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/deregister' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
 
 
 r = @@engines_api.force_deregister_attached_service(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end


get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)

  r = @@engines_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end
