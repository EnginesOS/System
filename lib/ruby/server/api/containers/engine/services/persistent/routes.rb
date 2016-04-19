get '/v0/containers/engine/:id/services/persistent/' do
  #engine = get_engine(params[:id])
  r = @@core_api.engine_persistent_services(params[:id])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end
get '/v0/containers/engine/:id/services/persistent/:ns/*' do
  splats = params['splat']
    

hash = {}
        hash[:publisher_namespace] = params['ns']
        hash[:parent_engine] = params['id']
        hash[:type_path] = splats[0]    

          
  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end