# @!group /system/system_services

# @method get_system_status_first_run
# @overload get '/v0/system/status/first_run_required'
# @return [true|false]

get '/v0/system/system_services' do
  begin
    return_json_array(engines_api.list_system_services)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_service_status
# @overload get '/v0/containers/system_service/:engine_name/status'
# get engine status
# @return [Hash] :state :set_state :progress_to :error
# test cd /opt/engines/tests/engines_api/engine ; make status
get '/v0/containers/system_service/:service_name/status' do
  begin
    return_json(engines_api.system_service_status(params[:service_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_service_state
# @overload  get '/v0/containers/system_service/:engine_name/state'
# get engine state
# @return [String] engine state
# test cd /opt/engines/tests/engines_api/engine ; make state
get '/v0/containers/system_service/:service_name/state' do
  begin

    return_text(engines_api.system_service_state(params[:service_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
