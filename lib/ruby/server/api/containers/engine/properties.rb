#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/engine/:id/properties/network' do

  engine = get_engine(params[:id])
  p :LOADED
  r = @@core_api.set_container_network_properties(engine, Utils.symbolize_keys(params))

  return log_error('set network properties', params) if r.is_a?(FalseClass)
  r.to_json
end

post '/v0/containers/engine/:engine_name/properties/runtime' do
#  address_params = [:engine_name]
#  accept_params = [:all]
#  cparams = assemble_params(params, address_params, accept_params )
#  cparams = address_params(params,  :engine_name) # , :variables)
#  vars = params[:api_vars]
#  Utils.symbolize_keys(vars)
#  cparams.merge!(vars)
  cparams =  assemble_params(params, :engine_name, :all) #accept_params )
  p cparams
  r =   @@core_api.set_engine_runtime_properties(cparams) #Utils.symbolize_keys(params))
  return log_error('set run time properties', params) if r.is_a?(FalseClass)
  r.to_json
end