get '/v0/containers/service/:id/configurations/' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  list = service.get_service_configurations()
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error('configurations', params)
  end
end

get '/v0/containers/service/:id/configuration/:configurator_name' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  cparams = {}
  cparams[:configurator_name] = params[:configurator_name]
  config = service.retrieve_configurator(cparams)
 
    unless config.is_a?(FalseClass) 
      config.to_json
  else
    return log_error('get configuration')
  end
end 

post '/v0/containers/service/:id/configuration/:configurator_name' do
  service = get_engine(params[:id])
   return false if service.is_a?(FalseClass)
  cparams = {}
  cparams[:configurator_name] = params[:configurator_name]
   r = service.run_configurator(cparams)
  unless r.is_a?(FalseClass) 
      r.to_json
  else
    return log_error('post configuration')
  end
end 