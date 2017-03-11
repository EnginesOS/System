# @!group  /system/control/base_os/

# @method restart_base_os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return [true]
get '/v0/system/control/base_os/restart' do
  restart = engines_api.restart_base_os
  return log_error(request, restart) if restart.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  restart.to_s
end
# @method shutdown_base_os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
# @param :reason
#  :reason
# @return [true]
post '/v0/system/control/base_os/shutdown' do
  p_params = post_params(request)
  cparams = assemble_params(p_params, [],  [:reason])
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  shutdown = cparams[:reason] #symbolize_keys(params)
  r = engines_api.halt_base_os(shutdown)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  r.to_s
end
# @method update_base_os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return [true|false]
get '/v0/system/control/base_os/update' do
  system_update = engines_api.update_base_os
  return log_error(request, system_update) if system_update.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  system_update.to_s
end
# @!endgroup