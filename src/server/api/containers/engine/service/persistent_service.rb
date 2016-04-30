
get '/v0/containers/engine/:engine_name/service/persistent/:ns/*/export' do
  content_type 'application/octet-stream'
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
   r = engine.export_service_data(hash)

  unless r.is_a?(EnginesError)
    return r.b
    #.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

post '/v0/containers/engine/:engine_name/service/persistent/:ns/*/import' do
  p params
  hash = {}
  hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:data]  = params[:data]
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

post '/v0/containers/engine/:engine_name/service/persistent/:ns/*/replace' do
  p params
  hash = {}
   hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
   engine = get_engine(params[:engine_name])
  hash[:import_method] == :replace  
  hash[:data] = params[:data]
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end


get '/v0/containers/engine/:engine_name/service/persistent/:ns/*' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)

  r = @@engines_api.find_engine_service_hash(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end
