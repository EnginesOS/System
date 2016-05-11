#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/service/:service_name/properties/network' do

  service = get_service(params[:service_name])
  p :LOADED
  return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(params, [:service_name],  :all) 
  r = engines_api.set_container_network_properties(service, cparams)

  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  r.to_json
end

post '/v0/containers/service/:service_name/properties/runtime' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(params, [:service_name],  :all) 
  r =   engines_api.set_container_runtime_properties(service, cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  r.to_json
end