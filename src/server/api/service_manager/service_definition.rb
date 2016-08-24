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
# @method get_service_definition
# @overload get '/v0/service_manager/service_definition/:service_name'
# return  Hash for service definition fro service name

# @return [Hash]
get '/v0/service_manager/service_definition/:service_name' do

 
   cparams =  Utils::Params.assemble_params(params, [:service_name], []) 
   r = get_service(cparams[:service_name])
  return r if r.is_a?(EnginesError)
  pparams = {}
  pparams[:publisher_namespace] = r.publisher_namespace
  pparams[:type_path] = r.type_path
    
    r = engines_api.get_service_definition(pparams)
   
    
  unless r.is_a?(EnginesError)
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end


# @!endgroup
