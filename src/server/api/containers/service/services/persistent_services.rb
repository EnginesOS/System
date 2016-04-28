get '/v0/containers/service/:service_name/services/persistent/' do
  service = get_service(params[:service_name])
  r = @@engines_api.list_persistent_services(service)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end



get '/v0/containers/service/:service_name/services/persistent/:ns/*' do
  splats = params['splat']
    
  hash = Utils::ServiceHash.service_service_hash_from_params(params)
#hash = {}
#        hash[:publisher_namespace] = params[:ns]
#        hash[:parent_engine] = params[:service_name]
#        hash[:type_path] = splats[0]    
#        hash[:ctype] = 'service'    
#p hash
          
  r = @@engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end