#  /system/control/engines_system/update
#/system/control/engines_system/restart
#/system/control/engines_system/update
#/system/control/engines_system/recreate

get '/v0/system/control/engines_system/update' do
  update = @@engines_api.update_engines_system_software
  unless update.is_a?(FalseClass)
    return update.to_json
  else
    return log_error(request, 'Might just be update to date update')
  end
end
get '/v0/system/control/engines_system/restart' do
  restart = @@engines_api.restart_mgmt
  unless restart.is_a?(FalseClass)
    return restart.to_json
  else
    return log_error(request)
  end
end

get '/v0/system/control/engines_system/recreate' do
  recreate = @@engines_api.recreate_mgmt
  unless recreate.is_a?(FalseClass)
    return recreate.to_json
  else
    return log_error(request)
  end
end
