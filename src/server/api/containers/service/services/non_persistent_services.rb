# @!group /containers/service/:service_name/services/non_persistent/
# @method get_service_non_persistent_services
# @overload get '/v0/containers/service/:service_name/services/non_persistent/'
# Return the non persistent services registered to the service (which this service consumes)
# @return [Array]
get '/v0/containers/service/:service_name/services/non_persistent/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = engines_api.list_non_persistent_services(service)
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end

# @method get_service_non_persistent_services_by_type
# @overload get '/v0/containers/service/:service_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the service (which this service consumes)
# @return [Array]

get '/v0/containers/service/:service_name/services/non_persistent/:publisher_namespace/*' do
  hash = Utils::ServiceHash.service_service_hash_from_params(params, true)
  r = engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  r.to_json
end

# @!endgroup