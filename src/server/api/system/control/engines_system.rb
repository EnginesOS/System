# @!group /system/control/engines_system
# @method update_engines_system
# @overload get '/v0/system/control/engines_system/update'
# Update the engines system
#  true > update update available and started
#  false > no udpdate available
#  EnginesError > an error occurred
# @return true.to_json|false.to_json|EnginesError.to_json
get '/v0/system/control/engines_system/update' do
  update = engines_api.update_engines_system_software
  unless update.is_a?(EnginesError)
    status(202)
    return update.to_json
  else
    return log_error(request, update, 'Might just be update to date update')
  end
end
# @method restart_engines_system
# @overload get '/v0/system/control/engines_system/restart'
#  Restart the engines system
# @return true.to_json|EnginesError.to_json
get '/v0/system/control/engines_system/restart' do
  restart = engines_api.restart_mgmt
  unless restart.is_a?(EnginesError)
    status(202)
    return restart.to_json
  else
    return log_error(request, restart)
  end
end
# @method recreate_engines_system
# @overload get '/v0/system/control/engines_system/recreate'
#  Recreate the engines system container
# @return true.to_json|EnginesError.to_json
get '/v0/system/control/engines_system/recreate' do
  recreate = engines_api.recreate_mgmt
  unless recreate.is_a?(EnginesError)
    status(202)
    return recreate.to_json
  else
    return log_error(request, recreate)
  end
end
# @method dump_engines_system_heap_stats
# @overload get '/v0/system/control/engines_system/heap_stats'
#  dump the heap stats engines system post CG output is written to /tmp/big/heap.dump
#  admin has access to this via ssh login 
#  the path is /opt/engines/tmp/system_service/system/heap.dump 
# @return true.to_json|EnginesError.to_json
 get '/v0/system/control/engines_system/heap_stats' do
      dump_stats = engines_api.dump_heap_stats
      unless dump_stats.is_a?(EnginesError)
        status(202)
        return dump_stats.to_json
      else
        return log_error(request, dump_stats)
      end
  
end
# @!endgroup