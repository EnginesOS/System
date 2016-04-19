
get '/v0/containers/engine/:id/service/non_persistent/:ns/*' do
  
  hash = service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end

get '/v0/containers/engine/:id/service/non_persistent/:ns/*/register' do
  
  hash = service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' register_service_hash')
  end
end

get '/v0/containers/engine/:id/service/non_persistent/:ns/*/reregister' do
  
  hash = service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' reregister_service_hash')
  end
end

get '/v0/containers/engine/:id/service/non_persistent/:ns/*/deregister' do
  
  hash = service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' deregister_service_hash')
  end
end