# @!group /service_manager/
# @method get_service_definitions
# @overload get '/v0/service_manager/service_definitions/:publisher_namespace/:type_path'
# return  Hash for service definition addressed by
#  :publisher_namespace :type_path
# @return [Hash]
get '/v0/service_manager/service_definitions/:publisher_namespace/*' do
  # splats = params['splat']
  # pparams =  {}
  # pparams[:publisher_namespace] = params[:publisher_namespace]
  params[:type_path] = params['splat'][0]

  cparams = assemble_params(params, [:publisher_namespace, :type_path], [])
  return log_error(request, cparams, params) if cparams.is_a?(EnginesError)
  r = engines_api.get_service_definition(cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  return_json(r)
end

# @!endgroup
