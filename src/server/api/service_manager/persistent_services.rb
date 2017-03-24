# @!group /service_manager/

# @method get_services_for_type
# @overload get '/v0/service_manager/persistent_services/:publisher_namespace/:type_path'
# Return array of services attached to the service :publisher_namespace/:type_path
# @return [Array]
get '/v0/service_manager/persistent_services/:publisher_namespace/*' do
  begin
    params[:type_path] = params['splat'][0]
    cparams = assemble_params(params, [:publisher_namespace, :type_path], [])
    return_json_array(engines_api.registered_with_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
