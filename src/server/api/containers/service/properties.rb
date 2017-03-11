# @!group /containers/service/:service_name/properties/
# @method set_service_properties_network
# @overload post '/v0/containers/service/:service_name/properties/network'
# @param :domain_name 
# @param :host_name 
# @param :protocol  https_only|http_only|http_and_https
#  
# @return [true]

post '/v0/containers/service/:service_name/properties/network' do
  p_params = post_params(request)
  p_params[:service_name] = params[:service_name]
  service = get_service(p_params[:service_name])
  return log_error(request, service, p_params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(p_params, [:service_name],  :all) 
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.set_container_network_properties(service, cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  return_text(r)
end
# @method set_service_properties_runtime
# @overload  post '/v0/containers/service/:service_name/properties/runtime' 
# @param :memory 
# @param :environment_variables Hash[env_name => env_value,]
# @return [true]

post '/v0/containers/service/:service_name/properties/runtime' do
  p_params = post_params(request)
  p_params[:service_name] = params[:service_name]
  service = get_service(p_params[:service_name])
  return log_error(request, service, p_params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(p_params, [:service_name],  :all) 
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.set_container_runtime_properties(service, cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  return_text(r)
end


# @!endgroup