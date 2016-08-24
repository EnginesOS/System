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
    r = engines_api.get_service_definition(cparams)
  unless r.is_a?(EnginesError)
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end


# @!endgroup
