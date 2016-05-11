# /system/control/base_os/restart
# /system/control/base_os/update
# /system/control/base_os/shutdown
get '/v0/system/control/base_os/restart' do
  restart = engines_api.restart_system
  unless restart.is_a?(EnginesError)
    status(202)
    return restart.to_json
  else
    return log_error(request, restart)
  end
end

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

get '/v0/system/control/base_os/update' do
  system_update = engines_api.system_update
  unless system_update.is_a?(EnginesError)
    status(202)
    return system_update.to_json
  else
    return log_error(request, system_update)
  end
end