# @!group /containers/engine/:engine_name/properties/

# @method set_engine_network_properties
# @overload post /v0/containers/engine/:engine_name/properties/network
# Set the network properties for :engine_name
# @param :host_name
# @param :domain_name
# @param :protocol  https_only|http_only|http_and_https
# @return [true]

post '/v0/containers/engine/:engine_name/properties/network' do
  begin
    p_params = post_params(request)
    p_params[:engine_name] = params[:engine_name]
    engine = get_engine(p_params[:engine_name])
    cparams = assemble_params(p_params, [:engine_name], :all) # [:memory, :environment_variables])
    r = engines_api.set_container_network_properties(engine, cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_engine_runtime_properties
# @overload post /v0/containers/engine/:engine_name/properties/runtime
# Set the runtime properties for :engine_name
# @param :memory
# @param :environment_variables Hash[env_name => env_value,]
# @return [true]
post '/v0/containers/engine/:engine_name/properties/runtime' do
  begin
    p_params = post_params(request)
    p_params[:engine_name] = params[:engine_name]
    cparams = assemble_params(p_params, [:engine_name], [], [:memory, :environment_variables])
    engine = get_engine(cparams[:engine_name])
    r = engines_api.set_container_runtime_properties(engine, cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
