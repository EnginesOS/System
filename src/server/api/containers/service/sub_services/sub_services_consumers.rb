# @method sub_services
# @overload get '/v0/containers/service/:service_name/sub_services'
# optional address params :engine_name, :service_handle
# return subservices attached to :service_name
# @return [Hash]
#
get '/v0/containers/service/:service_name/sub_services' do
  begin
    STDERR.puts("\nparams " + params.to_s)
    #  opt_param = [:engine_name, :service_handle]
    cparams = assemble_params(params, [:service_name], nil, [:engine_name, :service_handle])
    return_json_array(engines_api.subservices_provided(cparams)) #was subservices_provided
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method sub_services
# @overload get '/v0/containers/service/:service_name/sub_services/parent_engine{/service_handle}'
# optional address params :engine_name, :service_handle
# return subservices attached to :service_name
# @return [Hash]
#
get '/v0/containers/service/:service_name/sub_services/*' do
  begin
    STDERR.puts("\nparams " + params.to_s)
    #  opt_param = [:engine_name, :service_handle]
    unless params['splat'].nil?
      p = params['splat'][0]
      ps = p.split('/')
      params[:engine_name] = ps[0]
      params[:service_handle] = ps[1] if ps.length > 1
    end
    cparams = assemble_params(params, [:service_name], nil, [:engine_name, :service_handle])
    return_json_array(engines_api.subservices_provided(cparams)) #was subservices_provided
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
    STDERR.puts("\nparams " + params.to_s)

    hash = service_service_hash_from_params(params)
    STDERR.puts("\nHASH " + hash.to_s)

    p_params = post_params(request)
    STDERR.puts("\np_params " + p_params.to_s)
    hash.merge!(p_params)
    params.merge!(hash)
    STDERR.puts("\nparams " + params.to_s)
    cparams = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    STDERR.puts("\ncparams " + cparams.to_s)
    cparams[:parent_engine]= cparams[:engine_name]
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
    params[:parent_engine] = params[:engine_name]
    cparams = assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
    cparams[:parent_engine] = cparams[:engine_name]
    engines_api.update_subservice(cparams)
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
