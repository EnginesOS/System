# @!group /system/status

# @method get_system_status_first_run
# @overload get '/v0/system/status/first_run_required'
# @return [true|false]

get '/v0/system/status/first_run_required' do
  first_run_required = engines_api.first_run_required?
  status(202)
  return first_run_required.to_json # no checky as true or false

end

# @method get_system_status
# @overload get '/v0/system/status'
# @return [Hash] :is_rebooting :is_base_system_updating :is_engines_system_updating :needs_reboot
  
get '/v0/system/status' do
  status = SystemStatus.system_status
  unless status.is_a?(EnginesError)
    status(202)
    return status.to_json
  else
    return log_error(request,status )
  end
end

# @!endgroup