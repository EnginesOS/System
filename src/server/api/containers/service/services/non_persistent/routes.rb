
get '/v0/containers/service/:service_name/services/non_persistent/' do
  service = get_service(params[:service_name])
  r = @@engines_api.list_non_persistent_services(service)
  p :np_services_index
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end


get '/v0/containers/service/:service_name/services/non_persistent/:ns/*' do
  splats = params['splat']
    

hash = {}
        hash[:publisher_namespace] = params[:ns]
        hash[:parent_engine] = params[:service_name]
        hash[:type_path] = splats[0]    
          p :np_services_splat
p hash
          
  r = @@engines_api.find_engine_service_hash(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, hash)
  end
end