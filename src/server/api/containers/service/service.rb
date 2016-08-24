

# @!group /containers/service/:service_name

# @method get_service
# @overload get '/v0/containers/service/:service_name' 
# get service
# @return [Hash]
get '/v0/containers/service/:service_name' do
  service = get_service(params[:service_name])
  unless service.is_a?(EnginesError)
    return managed_container_as_json(service)
  else
    return log_error(request, service)
  end
end

# @method get_service_status
# @overload get '/v0/containers/service/:service_name/status' 
# get service status
# @return [Hash] :state :set_state :progress_to :error
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
# @overload  get '/v0/containers/service/:service_name/state' 
# get service state
# @return [String] service state
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

# @method get_service_websites
# @overload   get '/v0/containers/service/:service_name/websites'
# get service websites
# @return [String] 
get '/v0/containers/service/:service_name/websites' do
  service = get_service(params[:service_name])
   return log_error(request, service, params) if service.is_a?(EnginesError)
   r = service.web_sites
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @method get_service_logs
# @overload   get '/v0/containers/service/:service_name/logs'
# get service logs
# @return [String] 
get '/v0/containers/service/:service_name/logs' do
  service = get_service(params[:service_name])
   return log_error(request, service, params) if service.is_a?(EnginesError)
   r = service.logs_container()
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

# @method get_service_definition
# @overload get '/v0/containers/service/:service_name/service_definition'
# return  Hash for service definition for :service name

# @return [Hash] 
get '/v0/containers/service/:service_name/service_definition' do

   cparams =  Utils::Params.assemble_params(params, [:service_name], []) 
   r = get_service(cparams[:service_name])
  return r if r.is_a?(EnginesError)
  pparams = {}
  pparams[:publisher_namespace] = r.publisher_namespace
  pparams[:type_path] = r.type_path
    
    r = engines_api.get_service_definition(pparams)
   
    
  unless r.is_a?(EnginesError)
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end

# @!endgroup


