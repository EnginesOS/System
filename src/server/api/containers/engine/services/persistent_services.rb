get '/v0/containers/engine/:engine_name/services/persistent/' do
  engine = get_engine(params[:engine_name])
  r = @@engines_api.list_persistent_services(engine)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, params[:engine_name])
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
          
  r = @@engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end