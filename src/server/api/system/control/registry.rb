# @!group /system/control/registry/
# @method restart_registry
# @overload get '/v0/system/control/registry/restart'
# restart the registry container
# @return [true]
get '/v0/system/control/registry/restart' do
  restart_registry = engines_api.force_registry_restart
  return log_error(request, restart_registry) if restart_registry.is_a?(EnginesError)
    status(202)
  content_type 'text/plain' 
    restart_registry.to_s
end
#  get '/v0/system/control/regsitry/update' do
#    update = engines_api.update_registry
#    unless update.is_a?(FalseClass)
#      return update.to_json
#    else
#      return log_error('restart_registry')
#    end
#end
# @!endgroup