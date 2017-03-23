# @!group /service_manager/available_services

# @method services_available_for_managed_engine_type
# @overload get '/v0//service_manager/available_services/managed_engine'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/managed_engine' do
  begin
    avail = engines_api.load_avail_services_for_type('ManagedEngine')
    return_json(avail)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method services_available_for_managed_engine
# @overload get '/v0//service_manager/available_services/managed_engine/:managed_engine'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/managed_engine/:managed_engine' do
  begin
    avail = engines_api.load_avail_services_for_type('ManagedEngine')
    return_json(avail)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method services_available_for_type
# @overload get '/v0//service_manager/available_services/type/:type_path'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/type/*' do
  begin
    type_path = params[:splat][0]
    avail = engines_api.load_avail_services_for_type(type_path)
    return_json(avail)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @!endgroup