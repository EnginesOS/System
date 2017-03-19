# @!group /system/status

# @method get_system_status_first_run
# @overload get '/v0/system/status/first_run_required'
# @return [true|false]

get '/v0/system/status/first_run_required' do
  begin
    first_run_required = engines_api.first_run_required?
    return_text(first_run_required) # no checky as true or false
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method get_system_status
# @overload get '/v0/system/status'
# @return [Hash] :is_rebooting :is_base_system_updating :is_engines_system_updating :needs_reboot

get '/v0/system/status' do
  begin
    s_status = SystemStatus.system_status
    return_json(s_status)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method get_system_update_status
# @overload get '/v0/system/status/update'
# @return [Hash]  :engines_system :base_os
# :engines_system true|String with required updates listed
# :base_os true|String with required updates listed

get '/v0/system/status/update' do
  begin
    ustatus = SystemStatus.system_update_status
    return_json(ustatus)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @!endgroup