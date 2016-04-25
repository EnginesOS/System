
get '/v0/containers/engine/:engine_name/service/persistent/:ns/*/export' do
  content_type 'application/octet-stream'
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  return false if engine.is_a?(FalseClass)
   r = engine.export_service_data(hash)

  unless r.is_a?(FalseClass)
    return r.b
    #.to_json
  else
    return log_error(request, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/service/persistent/:ns/*/import' do
  
  hash = {}
  hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:data]  = params[:data]
  return false if engine.is_a?(FalseClass)
  r = engine.import_service_data(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, engine.last_error)
  end
end
get '/v0/containers/engine/:engine_name/service/persistent/:ns/*/replace' do
  
  hash = {}
   hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
   engine = get_engine(params[:engine_name])
  hash[:import_method] == :replace  
  hash[:data] = params[:data]
  return false if engine.is_a?(FalseClass)
  r = engine.import_service_data(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, engine.last_error)
  end
end


get '/v0/containers/engine/:engine_name/service/persistent/:ns/*' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)

  r = @@engines_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end
