
get '/v0/containers/service/:service_name/service/persistent/:ns/*/export' do
  content_type 'application/octet-stream'
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
   r = service.export_service_data(hash)

  unless r.is_a?(FalseClass)
    return r.b
    #.to_json
  else
    return log_error(service.last_error)
  end
end

get '/v0/containers/service/:service_name/service/persistent/:ns/*/import' do
  
  hash = {}
  hash[:service_connection] =  Utils::ServiceHash.service_service_hash_from_params(params)
  service = get_service(params[:service_name])
  hash[:data]  = params[:data]
  return false if service.is_a?(FalseClass)
  r = service.import_service_data(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(service.last_error)
  end
end
get '/v0/containers/engine/:service_name/service/persistent/:ns/*/replace' do
  
  hash = {}
   hash[:service_connection] =  Utils::ServiceHash.service_service_hash_from_params(params)
  service = get_service(params[:service_name])
  hash[:import_method] == :replace  
  hash[:data] = params[:data]
  return false if service.is_a?(FalseClass)
  r = engine.import_service_data(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(service.last_error)
  end
end


get '/v0/containers/service/:service_name/service/persistent/:ns/*' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)

  r = @@core_api.find_service_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(hash)
  end
end
