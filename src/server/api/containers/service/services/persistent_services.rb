# @!group /containers/service/:service_name/services/persistent/
# @method get_service_persistent_services
# @overload get '/v0/containers/service/:service_name/services/persistent/'
# Return the persistent services registered to the service (which this service consumes)
# @return [Array]
get '/v0/containers/service/:service_name/services/persistent/' do
  begin
    service = get_service(params[:service_name])
    return_json(engines_api.list_persistent_services(service))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_service_persistent_services_by_type
# @overload get '/v0/containers/service/:service_name/services/persistent/:publisher_namespace/:type_path'
# Return the persistent services matchedin the :publisher_namespace and :type_path registered to the service (which this service consumes)
# @return [Array]

get '/v0/containers/service/:service_name/services/persistent/:publisher_namespace/*' do
  begin
    hash = service_service_hash_from_params(params, true)
    return_json(engines_api.retrieve_engine_service_hashes(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
