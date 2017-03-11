# @!group /service_manager/available_services

# @method services_available_for_managed_engine_type
# @overload get '/v0//service_manager/available_services/managed_engine'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/managed_engine' do
  avail = engines_api.load_avail_services_for_type('ManagedEngine')
  return log_error(request, avail) if avail.is_a?(EnginesError)
  return_json(avail)

end
# @method services_available_for_managed_engine
# @overload get '/v0//service_manager/available_services/managed_engine/:managed_engine'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/managed_engine/:managed_engine' do
  avail = engines_api.load_avail_services_for_type('ManagedEngine')
  return log_error(request, avail) if avail.is_a?(EnginesError)
  return_json(avail)
end
# @method services_available_for_type
# @overload get '/v0//service_manager/available_services/type/:type_path'
# @return [Hash]
#:persistent => [ServiceDefinitionSummaries]
#:non_persistent => [ServiceDefinitionSummaries]
get '/v0/service_manager/available_services/type/*' do
  type_path = params[:splat][0]
  avail = engines_api.load_avail_services_for_type(type_path)
  return log_error(request, avail) if avail.is_a?(EnginesError)
  return_json(avail)
end

# @!endgroup