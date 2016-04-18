#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/engine/:id/properties/network' do
  params[:engine_name] = params[:id]

  r = @@core_api.set_engine_network_properties(Utils.symbolize_keys(params))

  return log_error('set network properties', params) if r.is_a?(FalseClass)
  r.to_json
end

post '/v0/containers/engine/:id/properties/runtime' do
  engine = get_engine(params[:id])
  p :LOADED
  r =   @@core_api.set_engine_runtime_properties(engine, Utils.symbolize_keys(params))
  return log_error('set run time properties', params) if r.is_a?(FalseClass)
  r.to_json
end