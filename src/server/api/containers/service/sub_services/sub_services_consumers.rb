get '/v0/containers/service/:service_name/sub_services' do
  begin
    #  opt_param = [:engine_name, :service_handle]
    params = assemble_params(params, [:service_name], nil, [:engine_name, :service_handle])
    return_json_array(engines_api.services_subservices(params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

post '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    engines_api.update_subservice(params)
    return_true
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

post '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    engines_api.attach_subservice(params)
    return_true
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

delete '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
    engines_api.remove_subservice(params)
    return_true
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  begin
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
    return_json(engines_api.attached_subservice(params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
