get '/v0/containers/engine/:engine_name/services/persistent/' do

  r = @@core_api.engine_persistent_services(params[:engine_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(params[:engine_name])
  end
end
get '/v0/containers/engine/:id/services/persistent/:ns/*' do
  splats = params['splat']
    

hash = {}
        hash[:publisher_namespace] = params[:ns]
        hash[:parent_engine] = params[:engine_name]
        hash[:type_path] = splats[0]    
        hash[:ctype] = 'container'    
p hash
          
  r = @@core_api.find_engine_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(hash)
  end
end