
get '/v0/containers/engine/:engine_name/services/non_persistent/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = @@engines_api.list_non_persistent_services(engine)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r,  engine.last_error)
  end
end


get '/v0/containers/engine/:engine_name/services/non_persistent/:ns/*' do

    
  hash = Utils::ServiceHash.engine_service_hash_from_params(params, true)
#hash = {}
#        hash[:publisher_namespace] = params[:ns]
#        hash[:parent_engine] = params[:engine_name]
#        hash[:type_path] = splats[0]    
p hash
          
  r = @@engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request,  r, hash)
  end
end