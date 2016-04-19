
get '/v0/containers/engine/:id/services/non_persistent/' do
  engine = get_engine(params[:id])
  r = @@core_api.list_non_persistent_services(engine)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end


get '/v0/containers/engine/:id/services/non_persistent/:ns/*' do
  splats = params['splat']
    

hash = {}
        hash[:publisher_namespace] = params['ns']
        hash[:parent_engine] = params['id']
        hash[:type_path] = splats[0]    
p hash
          
  r = @@core_api.find_engine_services_hashes(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end