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
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_service_status
# @overload get '/v0/containers/service/:service_name/status'
# get service status
# @return [Hash] :state :set_state :progress_to :error
get '/v0/containers/service/:service_name/status' do
  begin
    service = get_service(params[:service_name])
    return_json(service.status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_service_state
# @overload  get '/v0/containers/service/:service_name/state'
# get service state
# @return [String] service state
get '/v0/containers/service/:service_name/state' do
  begin
    service = get_service(params[:service_name])
    return_text(service.read_state)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_service_websites
# @overload   get '/v0/containers/service/:service_name/websites'
# get service websites
# @return [String]
get '/v0/containers/service/:service_name/websites' do
  begin
    service = get_service(params[:service_name])
    return_json_array(service.web_sites)
  rescue StandardError => e
    return_json(nil)
    #send_encoded_exception(request: request, exception: e)
  end
end
# @method get_service_logs
# @overload   get '/v0/containers/service/:service_name/logs'
# get service logs
# @return [String]
get '/v0/containers/service/:service_name/logs' do
  begin
    service = get_service(params[:service_name])
    return_json(service.logs_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_service_definition
# @overload get '/v0/containers/service/:service_name/service_definition'
# return  Hash for service definition for :service name

# @return [Hash]
get '/v0/containers/service/:service_name/service_definition' do
  begin
    cparams = assemble_params(params, [:service_name], [])
    r = get_service(cparams[:service_name])
    pparams = {
      publisher_namespace:  r.publisher_namespace,
      type_path: r.type_path
    }
    return_json(engines_api.get_service_definition(pparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_service_ps
# @overload get '/v0/containers/service/:service_name/ps'
# get engine process lists
# @return [Hash] keys Processes:[Array] Titles:[Array]
get '/v0/containers/service/:service_name/ps' do
  begin
    service = get_service(params[:service_name])
    return_json(service.ps_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method wait_for_service_statup
# @overload get '/v0/containers/service/:service/wait_for_statup'
#
# @return true|false
# test cd /opt/engines/tests/engines_api/service ; make service wait_for_startup
get '/v0/containers/service/:service_name/wait_for_startup/:timeout' do
  stream do |out|
    begin
      service = get_service(params[:service_name])
      return_boolean(service.wait_for_startup(params[:timeout].to_i))
    rescue StandardError => e
      send_encoded_exception(request: request, exception: e)
    end
  end
end

# @method wait_for_service
# @overload get '/v0/containers/service/:service/wait_for/:what'
#
# @return true|false
# test cd /opt/engines/tests/engines_api/service ; make service wait_for
get '/v0/containers/service/:service_name/wait_for/:what/:timeout' do
  stream do |out|
    begin
      service = get_service(params[:service_name])
      return_boolean(service.wait_for(params[:what], params[:timeout].to_i))
    rescue StandardError => e
      send_encoded_exception(request: request, exception: e)
    end
  end
end

# @!endgroup
