# @!group  /system/control/base_os/

# @method restart_base_os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return [true]
get '/v0/system/control/base_os/restart' do
  restart = engines_api.restart_system
  unless restart.is_a?(EnginesError)
    status(202)
    return restart.to_json
  else
    return log_error(request, restart)
  end
end
# @method shutdown_base_os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
# @param :reason
#  :reason
# @return [true]
post '/v0/system/control/base_os/shutdown' do
  p_params = post_params(request)
  cparams =  Utils::Params.assemble_params(p_params, [],  [:reason]) 
  shutdown = cparams[:reason] #symbolize_keys(params)
    r = engines_api.shutdown(shutdown)
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r, cparams)
  end
end
# @method update_base_os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return [true|false]
get '/v0/system/control/base_os/update' do
  system_update = engines_api.system_update
  unless system_update.is_a?(EnginesError)
    status(202)
    return system_update.to_json
  else
    return log_error(request, system_update)
  end
end
# @!endgroup