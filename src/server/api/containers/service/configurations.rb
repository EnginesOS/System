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

post '/v0/containers/service/:service_name/configuration/:configurator_name' do
 # aparams = Utils.symbolize_keys(params)
  cparams =  Utils::Params.assemble_params(params, [:service_name, :configurator_name], [:variables])

   r = @@engines_api.update_service_configuration(cparams)
  unless r.is_a?(FalseClass) 
      r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end 