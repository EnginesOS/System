# @!group System Metrics

# @method get_system_metrics_memory
# @overload get '/v0/system/metrics/memory'
# Return System Memory usage
#  values are integers and in bytes
# @return [Hash]
#  :total :free :buffers :file_cache :active :inactive :swap_total :swap_free
get '/v0/system/metrics/memory' do
  memory_info =  engines_api.get_system_memory_info #engines_api.get_system_memory_info
  unless memory_info.is_a?(EnginesError)
    status(202)
    return memory_info.to_json
  else
    return log_error(request, memory_info)
  end
end

# @method get_system_metrics_load
# @overload get '/v0/system/metrics/load'
# Return system load
#   :one is the one minute load average
#   :five is the five minute load average
#   :fithteen is the fithteen minute load average
#   :running is the number of preocesses running
#   :idle is the number of idle processes
# @return [Hash]
#  :one :five :fithteen :running :idle
get '/v0/system/metrics/load' do
  load_info = engines_api.get_system_load_info
  unless load_info.is_a?(EnginesError)
    status(202)
    return load_info.to_json
  else
    return log_error(request, load_info)
  end
end

# @method get_system_metrics_memory_statistics
# @overload get '/v0/system/metrics/memory/statistics'
# Return memory statistics for all containers
#  services and applications are [Hash]s 
#  container_name:{:maximum, :current, :limit}
# @return [Hash]
#  :containers {:applications, :services }

get '/v0/system/metrics/memory/statistics' do
  memory_statistics = MemoryStatistics.total_memory_statistics(engines_api)
  unless memory_statistics.is_a?(EnginesError)
    status(202)
    return memory_statistics.to_json
  else
    return log_error(request, memory_statistics)
  end
end

# @method get_system_metrics_disk
# @overload get '/v0/system/metrics/disks'
# NOT YET
# @return [Hash]
#  :device :mount :size :used :free 
get '/v0/system/metrics/disks' do
  disk_statistics = engines_api.get_disk_statistics
  status(202)
  unless disk_statistics.is_a?(EnginesError)
    return disk_statistics.to_json
  else
    return log_error(request, disk_statistics)
  end
end

# @method get_system_metrics_network
# @overload get '/v0/system/metrics/network'
# NOT YET
# @return [Hash]
#  :device :mount :size :used :free 
get '/v0/system/metrics/network' do
  net_statistics = engines_api.get_network_statistics
  status(202)
  unless net_statistics.is_a?(EnginesError)
    return net_statistics.to_json
  else
    return log_error(request, net_statistics)
  end
end
# @!endgroup