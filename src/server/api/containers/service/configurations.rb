# @!group /containers/service/:service_name/configurations/

# @method get_service_configurations
# @overload get '/v0/containers/service/:service_name/configurations/'
# @return [Array] service configurations Hash
get '/v0/containers/service/:service_name/configurations/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  list = service.get_service_configurations()
    unless list.is_a?(EnginesError)
      list.to_json
  else
    return log_error(request, list, service.last_error)
  end
end
# @method get_service_configuration
# @overload get '/v0/containers/service/:service_name/configuration/:configurator_name'
# @return [Hash] service configuration Hash
get '/v0/containers/service/:service_name/configuration/:configurator_name' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams = {}
  cparams[:configurator_name] = params[:configurator_name]
  config = service.retrieve_configurator(cparams)
 
    unless config.is_a?(EnginesError) 
      config.to_json
  else
    return log_error(request, config, service.last_error)
  end
end 
# @method set_service_configuration
# @overload post '/v0/containers/service/:service_name/configuration/:configurator_name'
# Post params to match configurators 
# @param keys to match configurator definition
# @return [true]  apply service configuration Hash
post '/v0/containers/service/:service_name/configuration/:configurator_name' do
  p_params = post_params(request)
  
  STDERR.puts( ' update_configuration_on_service ' + p_params.to_s)
  cparams =  Utils::Params.assemble_params(p_params, [:service_name, :configurator_name], [:variables])
  STDERR.puts( ' update_configuration_on_service ' + cparams.to_s)
   r = engines_api.update_service_configuration(cparams)
  unless r.is_a?(FalseClass) 
      r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end 