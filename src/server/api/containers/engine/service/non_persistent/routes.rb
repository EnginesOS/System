
get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/register' do
  
  hash = Utils.engine_service_hash_from_params(params)
  

  r = @@core_api.force_register_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' register_service_hash')
  end
end

get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/reregister' do
  
  hash = Utils.engine_service_hash_from_params(params)
 
  r = @@core_api.force_reregister_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' reregister_service_hash')
  end
end

get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*/deregister' do
  
  hash = Utils.engine_service_hash_from_params(params)
 
 
 r = @@core_api.force_deregister_attached_service(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' deregister_service_hash')
  end
end


get '/v0/containers/engine/:engine_name/service/non_persistent/:ns/*' do
  
  hash = Utils.engine_service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end
