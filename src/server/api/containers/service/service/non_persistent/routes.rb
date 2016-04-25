#
#get '/v0/containers/service/:service_name/service/non_persistent/' do
#  service = get_service(params[:service_name])
#  r = @@engines_api.list_non_persistent_services(service)
#
#  unless r.is_a?(FalseClass)
#    return r.to_json
#  else
#    return log_error('pause')
#  end
#end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/register' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
  
 service_hash = @@engines_api.find_service_service_hash(hash)
  return log_error(request, 'Service not found', hash) if service_hash.is_a?(FalseClass)
  r = @@engines_api.force_register_attached_service(service_hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/reregister' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
  service_hash = @@engines_api.find_service_service_hash(hash)
  return log_error(request, 'Service not found', hash) if service_hash.is_a?(FalseClass)
  r = @@engines_api.force_reregister_attached_service(service_hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/deregister' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
  service_hash = @@engines_api.find_service_service_hash(hash)
  return log_error(request, 'Service not found', hash) if service_hash.is_a?(FalseClass)
 r = @@engines_api.force_deregister_attached_service(service_hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*' do
  #splats = params['splat']
    p :raw_params
    p params
  hash = Utils::ServiceHash.service_service_hash_from_params(params)

#hash = {}
#        hash[:publisher_namespace] = params[:ns]
        
 #       hash[:type_path] = splats[0]
          p :compute_hah    
p hash
 
  r = @@engines_api.find_service_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, 'service not found', hash)
  end
  
  
end