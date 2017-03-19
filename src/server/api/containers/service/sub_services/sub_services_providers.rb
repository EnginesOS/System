get '/v0/containers/service/sub_service_providers/:service_handle/:publisher_namespace/*' do
  begin
    params[:type_path] = params['splat'][0]
    params =  Params.assemble_params(params, [:service_handle, :publisher_namespace, :type_path])
    r = engines_api.subservice_provided(params)
    return_json(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end

get '/v0/containers/services/sub_service_providers/:publish_namespace/*' do
  begin
    params[:type_path] = params['splat'][0]
    params = assemble_params(params, [ :publisher_namespace, :type_path])
    r = engines_api.subservices_provided(params)
    return_json(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end

