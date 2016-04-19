
get '/v0/containers/engine/:id/service/persistent/:ns/*/export' do
  content_type 'application/octet-stream'
  hash = Utils.service_hash_from_params(params)
  engine = get_engine(params[:id])
  return false if engine.is_a?(FalseClass)
   r = engine.export_service_data(hash)

  unless r.is_a?(FalseClass)
    return r.b
    #.to_json
  else
    return log_error(' export_service')
  end
end

get '/v0/containers/engine/:id/service/persistent/:ns/*/import' do
  
  hash = Utils.service_hash_from_params(params)
  engine = get_engine(params[:id])
  return false if engine.is_a?(FalseClass)
  r = engine.export_service_data(hash)
  


  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' import_service_')
  end
end
get '/v0/containers/engine/:id/service/persistent/:ns/*' do
  
  hash = Utils.service_hash_from_params(params)

  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' register_service_hash')
  end
end
