# @!group /service_manager/

# @method get_services_for_type
# @overload get '/v0/service_manager/persistent_services/:publisher_namespace/:type_path'
# Return array of services attached to the service :publisher_namespace/:type_path
# @return [Array]
get '/v0/service_manager/persistent_services/:publisher_namespace/*' do

  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = splats[0]

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path], [])
  r = engines_api.get_registered_against_service(cparams)

  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end

# @!endgroup