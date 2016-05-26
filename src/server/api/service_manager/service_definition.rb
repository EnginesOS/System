# @!group /service_manager/service_definitions/
# @method get_service_definition
# @overload get '/v0/service_manager/service_definitions/:publisher_namespace/:type_path'
# return Json Hash for service definition addressed by
#  :publisher_namespace :type_path
# @return [Hash|EnginesError]
get '/v0/service_manager/service_definitions/:publisher_namespace/:type_path' do
  cparams =  Utils::Params.assemble_params(params, [:publisher_namespace, :type_path], []) 
    r = engines_api.get_service_definition(cparams)
  unless r.is_a?(EnginesError)
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end
# @!endgroup
