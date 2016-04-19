get '/v0/containers/engine/:id/service/persistent/:ns/*' do
  
  hash = Utils.service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' register_service_hash')
  end
end
