

# @!group Service

get '/v0/containers/service/:service_name' do
  service = get_service(params[:service_name])
  unless service.is_a?(EnginesError)
    return service.to_json
  else
    return log_error(request, service)
  end
end

get '/v0/containers/service/:service_name/status' do
  service = get_service(params[:service_name])
 return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.read_status
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/containers/service/:service_name/state' do
  service = get_service(params[:service_name])
 return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.read_state
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @!endgroup


