# @!group /containers/engine/:engine_name/properties/

# @method set_engine_network_properties
# @overload post /v0/containers/engine/:engine_name/properties/network
# Set the network properties for :engine_name
# @param :host_name
# @param :domain_name
# @param :protocol  https_only|http_only|http_and_https
# @return [true]

post '/v0/containers/engine/:engine_name/properties/network' do
  p_params = post_params(request)
  p_params[:engine_name] = params[:engine_name]
  engine = get_engine(p_params[:engine_name])
  return log_error(request ,'failed to load ') unless engine.is_a?(ManagedEngine)
  cparams =  Utils::Params.assemble_params(p_params, [:engine_name], :all) # [:memory, :environment_variables])
  r = engines_api.set_container_network_properties(engine, cparams)
  return log_error(request , r,engine.last_error) if r.is_a?(EnginesError)
  r.to_json
end

# @method set_engine_runtime_properties
# @overload post /v0/containers/engine/:engine_name/properties/runtime
# Set the runtime properties for :engine_name
# @param :memory
# @param :environment_variables Hash[env_name => env_value,]
# @return [true]
post '/v0/containers/engine/:engine_name/properties/runtime' do
  p_params = post_params(request)
  p_params[:engine_name] = params[:engine_name]
  cparams =  Utils::Params.assemble_params(p_params, [:engine_name], [], [:memory, :environment_variables]) # :all)
  engine = get_engine(cparams[:engine_name])
  return log_error(request, engine, p_params) if engine.is_a?(EnginesError)
  r = engines_api.set_container_runtime_properties(engine, cparams) #Utils.symbolize_keys(params))
  return log_error(request , r, cparams) if r.is_a?(EnginesError)
  r.to_json
end

# @!endgroup