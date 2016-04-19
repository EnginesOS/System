
get '/v0/containers/engine/:id/service/non_persistent/:ns/*' do
  splats = params['splat']
    
      p params
     
      service_handle = splats[0].gsub(/^\/[A-Z_a-z].*\//,'')  
      p     service_handle
      
      type_path = splats[0].gsub('/' + '\/' +  service_handle +'/','')
      p type_path
hash = {}
        hash[:publisher_namespace] = params['ns']
        hash[:parent_engine] = params['id']
        hash[:type_path] = type_path
        hash[:service_handle] = service_handle
          p :HASHja
          p hash
  r = @@core_api.find_engine_service_hash(hash)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(' find_engine_service_hash')
  end
end