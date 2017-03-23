# @!group /containers/service/:service_name/services/non_persistent/
# @method get_service_non_persistent_services
# @overload get '/v0/containers/service/:service_name/services/non_persistent/'
# Return the non persistent services registered to the service (which this service consumes)
# @return [Array]
get '/v0/containers/service/:service_name/services/non_persistent/' do
  begin
    service = get_service(params[:service_name])
    r = engines_api.list_non_persistent_services(service)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_service_non_persistent_services_by_type
# @overload get '/v0/containers/service/:service_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the service (which this service consumes)
# @return [Array]

get '/v0/containers/service/:service_name/services/non_persistent/:publisher_namespace/*' do
  begin
    hash = service_service_hash_from_params(params, true)
    r = engines_api.find_engine_service_hashes(hash)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup
