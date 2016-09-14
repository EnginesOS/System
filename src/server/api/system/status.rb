# @!group /system/status

# @method get_system_status_first_run
# @overload get '/v0/system/status/first_run_required'
# @return [true|false]

get '/v0/system/status/first_run_required' do
  first_run_required = engines_api.first_run_required?
  return log_error(request,status ) if first_run_required.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  return first_run_required.to_s # no checky as true or false
end

# @method get_system_status
# @overload get '/v0/system/status'
# @return [Hash] :is_rebooting :is_base_system_updating :is_engines_system_updating :needs_reboot

get '/v0/system/status' do
  status = SystemStatus.system_status
  return log_error(request,status ) if status.is_a?(EnginesError)
  status(202)
  status.to_json
end
# @method get_system_update_status
# @overload get '/v0/system/status/update'
# @return [Hash] :needs_base_update :needs_engines_update
# :engines_system_is_up_to_date true|String 
# :base_os_is_up_to_date false|String of text with required updates listed

get '/v0/system/status/update' do
  status = SystemStatus.system_update_status
  return log_error(request,status ) if status.is_a?(EnginesError)
  status(202)
  status.to_json
end
# @!endgroup