
# @method sub_services
# @overload get '/v0/containers/service/:service_name/sub_services'
# optional address params :engine_name, :service_handle
# return subservices attached to :service_name
# @return [Hash]
#
get '/v0/containers/service/:service_name/sub_services' do
  begin
    #  opt_param = [:engine_name, :service_handle]
    params = assemble_params(params, [:service_name], nil, [:engine_name, :service_handle])
    return_json_array(engines_api.services_subservices(params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method create_sub_service
# @overload post '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle'
# create subservice addressed by :service_name :engine_name :service_handle :sub_handle with params from post
# @return [Hash]
#
post '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  begin
    STDERR.puts('params ' + params.to_s)
       
    hash = service_service_hash_from_params(params)
    STDERR.puts('HASH ' + hash.to_s)
    
    p_params = post_params(request)
    STDERR.puts('p_params ' + p_params.to_s)
    hash.merge!(p_params)
    params.merge!(hash)
    STDERR.puts('params ' + params.to_s)
    cparams = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    STDERR.puts('cparams ' + cparams.to_s)
    engines_api.attach_subservice(cparams)
    return_true
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method update_sub_service
# @overload post '/v0/containers/service/:service_name/sub_service/update/:engine_name/:service_handle/:sub_handle'
# create subservice addressed by :service_name :engine_name :service_handle :sub_handle with params from post
# @return [Hash]
#
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

# @method del_sub_service
# @overload delete '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle'
# deletesubservice addressed by :service_name :engine_name :service_handle :sub_handle
# @return [Boolean]
#
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

# @method get_sub_service
# @overload get '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle'
# return subservice addressed by :service_name :engine_name :service_handle :sub_handle
# @return [Hash]
#
get '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  begin
    params = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])
    return_json(engines_api.attached_subservice(params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
