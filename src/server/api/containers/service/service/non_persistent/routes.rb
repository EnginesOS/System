
get '/v0/containers/service/:service_name/service/non_persistent/' do
  service = get_service(params[:service_name])
  r = @@core_api.list_non_persistent_services(service)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end


get '/v0/containers/service/:service_name/service/non_persistent/:ns/*' do
  #splats = params['splat']
    p :raw_params
  hash = Utils.service_hash_from_params(params)

#hash = {}
#        hash[:publisher_namespace] = params[:ns]
        hash[:ctype] = 'service_name'
 #       hash[:type_path] = splats[0]
          p :compute_hah    
p hash
          
  r = @@core_api.find_engine_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end