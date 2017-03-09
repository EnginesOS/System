get '/v0/containers/service/:service_name/sub_services' do
#  opt_param = [:engine_name, :service_handle]
 params =  Params.assemble_params(params, [:service_name], nil, [:engine_name, :service_handle] )
  return log_error(request, params)  if params.is_a?(EnginesError)
  r = engines_api.services_subservices(params)
  return log_error(request, r) if r.is_a?(EnginesError)
  return empty_array if r.nil?
  r.to_json
end

post '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  params.merge!(post_params(request))
  params =  Params.assemble_params(params, [:service_name,:engine_name,:service_handle,:sub_handle], nil, :all)
  return log_error(request, params)  if params.is_a?(EnginesError)
  r = engines_api.update_subservice(params)
    return log_error(request, r) if r.is_a?(EnginesError)
  content_type 'text/plain' 
  'true'
end

post '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  params.merge!(post_params(request))
  params =  Params.assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle], nil, :all)
  return log_error(request, params)  if params.is_a?(EnginesError)
  r = engines_api.attach_subservice(params)
    return log_error(request, r) if r.is_a?(EnginesError)
  content_type 'text/plain' 
  'true'
  
end

delete '/v0/containers/service/:service_name/sub_services/:engine_name/:service_handle/:sub_handle' do
  params.merge!(post_params(request))
  params =  Params.assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])    
  return log_error(request, params)  if params.is_a?(EnginesError)
  r = engines_api.remove_subservice(params)
    return log_error(request, r) if r.is_a?(EnginesError)
  content_type 'text/plain' 
  'true'
end

get '/v0/containers/service/:service_name/sub_service/:engine_name/:service_handle/:sub_handle' do
  params =  Params.assemble_params(params, [:service_name, :engine_name, :service_handle, :sub_handle])    
  return log_error(request, params)  if params.is_a?(EnginesError)
  r = engines_api.attached_subservice(params)
    return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end


