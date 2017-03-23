# @!group /system/control/engines_system
# @method update_engines_system
# @overload get '/v0/system/control/engines_system/update'
# Update the engines system
#  true > update update available and started
#  false > no udpdate available
#  EnginesError > an error occurred
# @return [true|false]
get '/v0/system/control/engines_system/update' do
  begin
    update = engines_api.update_engines_system_software
    return log_error(request, update, 'Might just be update to date update') if update.is_a?(EnginesError)
    return_text(update)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method restart_engines_system
# @overload get '/v0/system/control/engines_system/restart'
#  Restart the engines system
# @return [true]
get '/v0/system/control/engines_system/restart' do
  begin
    restart = engines_api.restart_engines_system_service
    return_text(restart)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method recreate_engines_system
# @overload get '/v0/system/control/engines_system/recreate'
#  Recreate the engines system container
# @return [true]
get '/v0/system/control/engines_system/recreate' do
  begin
    recreate = engines_api.recreate_engines_system_service
    return_text(recreate)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method dump_engines_system_heap_stats
# @overload get '/v0/system/control/engines_system/heap_stats'
#  dump the heap stats engines system post CG output is written to /tmp/big/heap.dump
#  admin has access to this via ssh login
#  the path is /opt/engines/tmp/system_service/system/heap.dump
# @return [true]
get '/v0/system/control/engines_system/heap_stats' do
  begin
    dump_stats = engines_api.dump_heap_stats
    return_text(dump_stats)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
