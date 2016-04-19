
get '/v0/containers/engine/:id/service/non_persistent/:ns/*' do
  splats = params['splat']
         
  type_path = File.dirname(splats[0])       
   service_handle = File.basename(splats[0])  

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