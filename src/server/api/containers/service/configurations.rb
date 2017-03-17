# @!group /containers/service/:service_name/configurations/

# @method get_service_configurations
# @overload get '/v0/containers/service/:service_name/configurations/'
# @return [Array] service configurations Hash
get '/v0/containers/service/:service_name/configurations/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  list = service.get_service_configurations()
  return log_error(request, list, service.last_error) if list.is_a?(EnginesError)  
  return_json_array(list)
end
# @method get_service_configuration
# @overload get '/v0/containers/service/:service_name/configuration/:configurator_name'
# @return [Hash] service configuration Hash
get '/v0/containers/service/:service_name/configuration/:configurator_name' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
#cparams = 
  config = service.retrieve_configurator({configurator_name:  params[:configurator_name] })
  return log_error(request, config, service.last_error) if  config.is_a?(EnginesError)
  return_json(config)
end
# @method set_service_configuration
# @overload post '/v0/containers/service/:service_name/configuration/:configurator_name'
# Post :variables,:service_name, :configurator_name]
# @param [Hash] key :variables [Hash] of  variable_name => variable_value
# @return [true]  apply service configuration Hash
post '/v0/containers/service/:service_name/configuration/:configurator_name' do
  p_params = post_params(request)
  p_params.merge!(params)
 # STDERR.puts(" post config " + p_params.to_s)
  
  cparams = assemble_params(p_params, [:service_name, :configurator_name], [:variables])
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)  
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)  
  cparams[:type_path] = service.type_path
  cparams[:publisher_namespace]  = service.publisher_namespace
  r = engines_api.update_service_configuration(cparams)
  return log_error(request, r, r) if r.is_a?(FalseClass) || r.is_a?(EnginesError)
  return_text(r)
end 