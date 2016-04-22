#
#get '/v0/containers/service/:service_name/service/non_persistent/' do
#  service = get_service(params[:service_name])
#  r = @@core_api.list_non_persistent_services(service)
#
#  unless r.is_a?(FalseClass)
#    return r.to_json
#  else
#    return log_error('pause')
#  end
#end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/register' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
  

  r = @@core_api.force_register_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' register_service_hash')
  end
end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/reregister' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
 
  r = @@core_api.force_reregister_attached_service(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' reregister_service_hash')
  end
end

get '/v0/containers/service/:service_name/service/non_persistent/:ns/*/deregister' do
  
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
 
 
 r = @@core_api.force_deregister_attached_service(hash)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' deregister_service_hash')
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
 
  r = @@core_api.find_service_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
  
  
end