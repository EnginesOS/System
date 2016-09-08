# @!group /service_manager/
# @method get_service_definitions
# @overload get '/v0/service_manager/service_definitions/:publisher_namespace/:type_path'
# return  Hash for service definition addressed by
#  :publisher_namespace :type_path
# @return [Hash]
get '/v0/service_manager/service_definitions/:publisher_namespace/*' do
  splats = params['splat']
  pparams =  {}
  pparams[:publisher_namespace] = params[:publisher_namespace]
  pparams[:type_path] = splats[0]

  cparams =  Utils::Params.assemble_params(pparams, [:publisher_namespace, :type_path], [])
return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.get_service_definition(cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  status(202)
  r.to_json
end

# @!endgroup
