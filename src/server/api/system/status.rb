# @!group /system/status

# @method get_system_status_first_run
# @overload get '/v0/system/status/first_run_required'
# @return [true|false]
#test cd /opt/engines/tests/engines_tool/system/system_status ;  make  first_run_required

get '/v0/system/status/first_run_required' do
  begin
    return_text(engines_api.first_run_required?)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_status
# @overload get '/v0/system/status'
# @return [Hash] :is_rebooting :is_base_system_updating :is_engines_system_updating :needs_reboot
#test cd /opt/engines/tests/engines_tool/system/system_status ;  make  status
get '/v0/system/status' do
  begin
    return_json(SystemStatus.system_status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_update_status
# @overload get '/v0/system/status/update'
# @return [Hash]  :engines_system :base_os
# :engines_system true|String with required updates listed
# :base_os true|String with required updates listed

get '/v0/system/status/update' do
  begin
    return_json(SystemStatus.system_update_status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
