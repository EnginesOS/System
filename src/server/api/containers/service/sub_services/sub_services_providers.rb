get '/v0/containers/service/sub_service_providers/:service_handle/:publisher_namespace/*' do
  params[:type_path] = params['splat'][0]
  params =  Params.assemble_params(params, [:service_handle, :publisher_namespace, :type_path])
  return log_error(request, params) if params.is_a?(EnginesError)
  r = engines_api.subservice_provided(params)
  return log_error(request, r) if r.is_a?(EnginesError)
  return_json(r)
end

get '/v0/containers/services/sub_service_providers/:publish_namespace/*' do
  params[:type_path] = params['splat'][0]
  params =  Params.assemble_params(params, [ :publisher_namespace, :type_path])
  return log_error(request, params) if params.is_a?(EnginesError)
  r = engines_api.subservices_provided(params)
  return log_error(request, r) if r.is_a?(EnginesError)
  r.return_json(r)
end

