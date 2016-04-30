#/system/control/regsitry/restart

get '/v0/system/control/registry/restart' do
  restart_registry = @@engines_api.force_registry_restart
  unless restart_registry.is_a?(FalseClass)
    return restart_registry.to_json
  else
    return log_error(request, restart_registry)
  end
end
#  get '/v0/system/control/regsitry/update' do
#    update = @@engines_api.update_registry
#    unless update.is_a?(FalseClass)
#      return update.to_json
#    else
#      return log_error('restart_registry')
#    end
#end