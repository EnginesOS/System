#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/service/:id/properties/network' do

  service = get_service(params[:id])
  p :LOADED
  return log_error('set network properties', params) if service.is_a?(FalseClass)
  r = @@core_api.set_container_network_properties(service, Utils.symbolize_keys(params))

  return log_error('set network properties', params) if r.is_a?(FalseClass)
  r.to_json
end

post '/v0/containers/service/:id/properties/runtime' do
  params[:engine_name] = params[:id]
  r =   @@core_api.set_service_runtime_properties(Utils.symbolize_keys(params))
  return log_error('set run time properties', params) if r.is_a?(FalseClass)
  r.to_json
end