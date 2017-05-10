# @!group /system/control/engines_system

# @method update_engines_system
# @overload get '/v0/system/control/engines_system/update'
# Update the engines system
#  true > update update available and started
#  false > no udpdate available
#  EnginesError > an error occurred
# @return [true|false]
# test cd /opt/engines/tests/engines_tool/system/control/engines_system; make update
get '/v0/system/control/engines_system/update' do
  begin
    return_text(engines_api.update_engines_system_software)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restart_engines_system
# @overload get '/v0/system/control/engines_system/restart'
#  Restart the engines system
# @return [true]
# test cd /opt/engines/tests/engines_tool/system/control/engines_system; make restart
get '/v0/system/control/engines_system/restart' do
  begin
    return_text(engines_api.restart_engines_system_service)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method recreate_engines_system
# @overload get '/v0/system/control/engines_system/recreate'
#  Recreate the engines system container
# @return [true]
# test cd /opt/engines/tests/engines_tool/system/control/engines_system; make recreate
get '/v0/system/control/engines_system/recreate' do
  begin
    return_text(engines_api.recreate_engines_system_service)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
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
    return_text(engines_api.dump_heap_stats)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method dump_engines_system_heap_stats
# @overload get '/v0/system/control/engines_system/heap_stats'
#  dump the heap stats engines system post CG output is written to /tmp/big/heap.dump
#  admin has access to this via ssh login
#  the path is /opt/engines/tmp/system_service/system/heap.dump
# @return [String]
get '/v0/system/control/engines_system/dump_threads' do
  begin
    return_text(engines_api.dump_threads)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
