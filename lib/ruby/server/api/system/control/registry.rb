
  #/system/control/regsitry/restart
  
get '/v0/system/control/regsitry/restart' do
  restart_registry = @@core_api.restart_registry
  unless restart_registry.is_a?(FalseClass)
    return restart_registry.to_json
  else
    return log_error('restart_registry')
  end
end
  get '/v0/system/control/regsitry/update' do
    update = @@core_api.update_registry
    unless update.is_a?(FalseClass)
      return update.to_json
    else
      return log_error('restart_registry')
    end
end