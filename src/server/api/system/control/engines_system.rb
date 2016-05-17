# @!group System Control Engines System

get '/v0/system/control/engines_system/update' do
  update = engines_api.update_engines_system_software
  unless update.is_a?(EnginesError)
    status(202)
    return update.to_json
  else
    return log_error(request, update, 'Might just be update to date update')
  end
end
get '/v0/system/control/engines_system/restart' do
  restart = engines_api.restart_mgmt
  unless restart.is_a?(EnginesError)
    status(202)
    return restart.to_json
  else
    return log_error(request, restart)
  end
end

get '/v0/system/control/engines_system/recreate' do
  recreate = engines_api.recreate_mgmt
  unless recreate.is_a?(EnginesError)
    status(202)
    return recreate.to_json
  else
    return log_error(request, recreate)
  end
end

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