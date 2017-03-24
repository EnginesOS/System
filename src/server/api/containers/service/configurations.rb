# @!group /containers/service/:service_name/configurations/

# @method retrieve_service_configurations
# @overload get '/v0/containers/service/:service_name/configurations/'
# @return [Array] service configurations Hash
get '/v0/containers/service/:service_name/configurations/' do
  begin
    service = get_service(params[:service_name])
    list = service.retrieve_service_configurations
    return_json_array(list)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method retrieve_service_configuration
# @overload get '/v0/containers/service/:service_name/configuration/:configurator_name'
# @return [Hash] service configuration Hash
get '/v0/containers/service/:service_name/configuration/:configurator_name' do
  begin
    service = get_service(params[:service_name])
    config = service.retrieve_configurator(configurator_name: params[:configurator_name])
    return_json(config)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method set_service_configuration
# @overload post '/v0/containers/service/:service_name/configuration/:configurator_name'
# Post :variables,:service_name, :configurator_name]
# @param [Hash] key :variables [Hash] of  variable_name => variable_value
# @return [true]  apply service configuration Hash
post '/v0/containers/service/:service_name/configuration/:configurator_name' do
  begin
    p_params = post_params(request)
    p_params.merge!(params)
    cparams = assemble_params(p_params, [:service_name, :configurator_name], [:variables])
    service = get_service(params[:service_name])
    cparams[:type_path] = service.type_path
    cparams[:publisher_namespace] = service.publisher_namespace
    r = engines_api.update_service_configuration(cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
