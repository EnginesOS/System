#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/engine/:engine_name/properties/network' do

  engine = get_engine(params[:engine_name])
  return log_error('failed to load ') unless engine.is_a?(ManagedEngine)
  
  cparams =  assemble_params(params, [:engine_name], :all) # [:memory, :environment_variables]) 
  r = @@core_api.set_container_network_properties(engine, cparams)

  return log_error('set network properties', params) if r.is_a?(FalseClass)
  r.to_json
end

post '/v0/containers/engine/:engine_name/properties/runtime' do

  cparams =  assemble_params(params, [:engine_name], [:memory, :environment_variables]) # :all) 

  r =   @@core_api.set_engine_runtime_properties(cparams) #Utils.symbolize_keys(params))
  return log_error('set run time properties', params) if r.is_a?(FalseClass)
  r.to_json
end