
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
    
      p params
     
      service_handle = splats[0].gsub(/^\/[A-Z_a-z].*\//,'')      
      type_path = splats[0].gsub('/' + '\/' +  service_handle +'/','')
      hash = []
        hash[:publisher_namespace] = params['ns']
        hash[:parent_engine] = params['id']
        hash[:type_path] = type_path
        hash[:service_handle] = service_handle
          
  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end