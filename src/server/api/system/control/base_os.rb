# /system/control/base_os/restart
# /system/control/base_os/update
# /system/control/base_os/shutdown
get '/v0/system/control/base_os/restart' do
  restart = @@engines_api.restart_system
  unless restart.is_a?(FalseClass)
    return restart.to_json
  else
    return log_error('restart')
  end
end

post '/v0/system/control/base_os/shutdown' do
  cparams =  Utils::Params.assemble_params(params, [],  [:reason]) 
  shutdown = cparams[:reason] #symbolize_keys(params)
  unless @@engines_api.shutdown(shutdown).is_a?(FalseClass)
    return status(202)
  else
    return log_error('shutdown', params)
  end
end

get '/v0/system/control/base_os/update' do
  system_update = @@engines_api.system_update
  unless system_update.is_a?(FalseClass)
    return system_update.to_json
  else
    return log_error('system_update')
  end
end