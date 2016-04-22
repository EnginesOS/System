get '/v0/containers/service/:service_name/services/persistent/' do
  service = get_service(params[:service_name])
  r = @@core_api.list_persistent_services(service)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end



get '/v0/containers/service/:service_name/services/persistent/:ns/*' do
  splats = params['splat']
    

hash = {}
        hash[:publisher_namespace] = params[:ns]
        hash[:parent_engine] = params[:service_name]
        hash[:type_path] = splats[0]    
        hash[:ctype] = 'service'    
p hash
          
  r = @@core_api.find_engine_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(hash)
  end
end