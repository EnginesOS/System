#/containers/engine/container_name/runtime_properties
#/containers/engine/container_name/network_properties

post '/v0/containers/engine/:engine_name/properties/network' do

  engine = get_engine(params[:engine_name])
  return log_error(request ,'failed to load ') unless engine.is_a?(ManagedEngine)
  
  cparams =  Utils::Params.assemble_params(params, [:engine_name], :all) # [:memory, :environment_variables]) 
  r = @@engines_api.set_container_network_properties(engine, cparams)

  return log_error(request ,engine.last_error) if r.is_a?(FalseClass)
  r.to_json
end

post '/v0/containers/engine/:engine_name/properties/runtime' do

  cparams =  Utils::Params.assemble_params(params, [:engine_name], [:memory, :environment_variables]) # :all) 
  engine = get_engine(params[:engine_name])
  r =   @@engines_api.set_container_runtime_properties(engine, cparams) #Utils.symbolize_keys(params))
  return log_error(request , cparams) if r.is_a?(FalseClass)
  r.to_json
end