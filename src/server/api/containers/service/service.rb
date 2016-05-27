

# @!group /containers/service/:service_name

# @method get_service
# @overload post  get '/v0/containers/service/:service_name' 
# get service
# @return [Hash]
get '/v0/containers/service/:service_name' do
  service = get_service(params[:service_name])
  unless service.is_a?(EnginesError)
    return service.to_json
  else
    return log_error(request, service)
  end
end

# @method get_service_status
# @overload post  get '/v0/containers/service/:service_name/status' 
# get service status
#   :state :set_state :progress_to :error
# @return [Hash]
get '/v0/containers/service/:service_name/status' do
  service = get_service(params[:service_name])
 return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.status
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @method get_service_state
# @overload post  get '/v0/containers/service/:service_name/state' 
# get service statue
# @return [String]
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


