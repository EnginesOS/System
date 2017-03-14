# @!group /service_manager/

# @method get_services_for_type
# @overload get '/v0/service_manager/persistent_services/:publisher_namespace/:type_path'
# Return array of services attached to the service :publisher_namespace/:type_path
# @return [Array]
get '/v0/service_manager/persistent_services/:publisher_namespace/*' do

  #splats = params['splat']
 # pparams =  {}
  #pparams[:publisher_namespace] = params[:publisher_namespace]
  params[:type_path] = params['splat'][0]

  cparams = assemble_params(params, [:publisher_namespace, :type_path], [])
return log_error(request, cparams, params) if cparams.is_a?(EnginesError)
  r = engines_api.get_registered_against_service(cparams)

  return log_error(request, r) if r.is_a?(EnginesError)
  return_json_array(r)
end

# @!endgroup