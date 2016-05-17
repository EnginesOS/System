# @!group System Control Base OS 

# @method restart base os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return true.to_json|EnginesError.to_json
get '/v0/system/control/base_os/restart' do
  restart = engines_api.restart_system
  unless restart.is_a?(EnginesError)
    status(202)
    return restart.to_json
  else
    return log_error(request, restart)
  end
end
# @method shutdown base os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
#  :reason
# @return true.to_json|EnginesError.to_json
post '/v0/system/control/base_os/shutdown' do
  cparams =  Utils::Params.assemble_params(params, [],  [:reason]) 
  shutdown = cparams[:reason] #symbolize_keys(params)
    r = engines_api.shutdown(shutdown)
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r, cparams)
  end
end
# @method update base os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return true.to_json|EnginesError.to_json
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