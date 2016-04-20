get '/v0/containers/service/:service_name/configurations/' do
  service = get_service(params[:service_name])
  return false if service.is_a?(FalseClass)
  list = service.get_service_configurations()
    unless list.is_a?(FalseClass)
      list.to_json
  else
    return log_error('configurations', params)
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
    return log_error('get configuration')
  end
end 

post '/v0/containers/service/:service_name/configuration/:configurator_name' do
  cparams = require_params(params, :configurator_name, :service_name) # , :variables)
  vars = require_params(params, :variables)
  p vars
  p :from 
  p params
  cparams.merge!(require_params(params, :variables)[:variables])

#  cparams = {}
#  cparams[:configurator_name] = params[:configurator_name]
#  cparams[:service_name] = params[:service_name]         
#  cparams[:variables] = Utils.symbolize_keys(params)
  p :CPRA
  p cparams
  #cparams[:configurator_name] = params[:configurator_name]
  #params[:configurator_name].to_s + '.sh \'' + SystemUtils.hash_variables_as_json_str(configurator_params[:variables]).
   r = @@core_api.update_service_configuration(cparams)
  unless r.is_a?(FalseClass) 
      r.to_json
  else
    return log_error('post configuration')
  end
end 