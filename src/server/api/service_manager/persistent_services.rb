# @!group /service_manager/persistent_services/

get '/v0/service_manager/persistent_service/:publisher_namespace/*' do
 
  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = File.dirname(splats[0])
  pparams[:service_handle] = File.basename(pparams[:type_path])
  pparams[:type_path] = File.dirname(pparams[:type_path])
  pparams[:parent_engine] = File.basename(splats[0])

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
  r = engines_api.fets(cparams)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/service_manager/persistent_services/:publisher_namespace/*' do
 
  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = splats[0]
  

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path], [])
  r = engines_api.get_registered_against_service(cparams)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

# @!endgroup