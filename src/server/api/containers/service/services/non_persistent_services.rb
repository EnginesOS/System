
get '/v0/containers/service/:service_name/services/non_persistent/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = @@engines_api.list_non_persistent_services(service)
  p :np_services_index
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end


get '/v0/containers/service/:service_name/services/non_persistent/:ns/*' do
  
    
  hash = Utils::ServiceHash.service_service_hash_from_params(params, true)
#hash = {}
#        hash[:publisher_namespace] = params[:ns]
#        hash[:parent_engine] = params[:service_name]
#        hash[:type_path] = splats[0]    
          p :np_services_splat
p hash
          
  r = @@engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end