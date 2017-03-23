get '/v0/containers/service/:service_name/sub_services' do
  begin
    #  opt_param = [:engine_name, :service_handle]
    params = assemble_params(params, [:service_name], nil, [:engine_name, :service_handle])
    r = engines_api.services_subservices(params)
    return empty_array if r.nil?
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

post '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    engines_api.update_subservice(params)
    return_true
  rescue StandardError => e
    log_error(request, e)
  end
end

post '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    engines_api.attach_subservice(params)
    return_true
  rescue StandardError => e
    log_error(request, e)
  end
end

delete '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  begin
    params.merge!(post_params(request))
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
    engines_api.remove_subservice(params)
    return_true
  rescue StandardError => e
    log_error(request, e)
  end
end

get '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  begin
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
    r = engines_api.attached_subservice(params)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
