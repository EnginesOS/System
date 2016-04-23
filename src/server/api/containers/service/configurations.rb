get '/v0/containers/service/:service_name/configurations/' do
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
  list = service.get_service_configurations()
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error(service.log_error, params)
  end
end

get '/v0/containers/service/:service_name/configuration/:configurator_name' do
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
  cparams = {}
  cparams[:configurator_name] = params[:configurator_name]
  config = service.retrieve_configurator(cparams)
 
    unless config.is_a?(FalseClass) 
      config.to_json
  else
    return log_error(service.log_error)
  end
end 

post '/v0/containers/service/:service_name/configuration/:configurator_name' do
 # aparams = Utils.symbolize_keys(params)
  cparams =  Utils::Params.assemble_params(params, [:service_name, :configurator_name], [:variables])

   r = @@engines_api.update_service_configuration(cparams)
  unless r.is_a?(FalseClass) 
      r.to_json
  else
    return log_error(service.log_error)
  end
end 