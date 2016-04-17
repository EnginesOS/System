
  #/system/status Get
  #/system/status/first_run_has_run

get '/v0/status/first_run_has_run' do
  first_run_required = @@core_api.first_run_required
  unless first_run_required.is_a?(FalseClass)
    return first_run_required.to_json
  else
    return log_error('first_run_required')
  end
end

get '/v0/system/status' do
  status = SystemStatus.system_status
  unless status.is_a?(FalseClass)
    return status.to_json
  else
    return log_error('status')
  end
end
