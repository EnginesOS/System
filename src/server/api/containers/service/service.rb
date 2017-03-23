# @!group /containers/service/:service_name

# @method get_service
# @overload get '/v0/containers/service/:service_name'
# get service
# @return [Hash]
get '/v0/containers/service/:service_name' do
  begin
    service = get_service(params[:service_name])
    managed_container_as_json(service)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_service_status
# @overload get '/v0/containers/service/:service_name/status'
# get service status
# @return [Hash] :state :set_state :progress_to :error
get '/v0/containers/service/:service_name/status' do
  begin
    service = get_service(params[:service_name])
    r = service.status
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_service_state
# @overload  get '/v0/containers/service/:service_name/state'
# get service state
# @return [String] service state
get '/v0/containers/service/:service_name/state' do
  begin
    service = get_service(params[:service_name])
    r = service.read_state
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_service_websites
# @overload   get '/v0/containers/service/:service_name/websites'
# get service websites
# @return [String]
get '/v0/containers/service/:service_name/websites' do
  begin
    service = get_service(params[:service_name])
    r = service.web_sites
    return_json_array(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_service_logs
# @overload   get '/v0/containers/service/:service_name/logs'
# get service logs
# @return [String]
get '/v0/containers/service/:service_name/logs' do
  begin
    service = get_service(params[:service_name])
    r = service.logs_container()
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_service_definition
# @overload get '/v0/containers/service/:service_name/service_definition'
# return  Hash for service definition for :service name

# @return [Hash]
get '/v0/containers/service/:service_name/service_definition' do
  begin
    #STDERR.puts('/v0/containers/service/:service_name/service_definition' )
    cparams = assemble_params(params, [:service_name], [])
    r = get_service(cparams[:service_name])
    pparams = {}
    pparams[:publisher_namespace] = r.publisher_namespace
    pparams[:type_path] = r.type_path
    r = engines_api.get_service_definition(pparams)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_service_ps
# @overload get '/v0/containers/service/:service_name/ps'
# get engine process lists
# @return [Hash] keys Processes:[Array] Titles:[Array]
get '/v0/containers/service/:service_name/ps' do
  begin
    service = get_service(params[:service_name])
    r = service.ps_container
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup

