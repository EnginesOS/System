# @!group /system/metrics/

# @method get_system_metrics_memory
# @overload get '/v0/system/metrics/memory'
# Return System Memory usage
#  values are integers and in bytes
# @return [Hash] :total :free :buffers :file_cache :active :inactive :swap_total :swap_free
#
get '/v0/system/metrics/memory' do
  begin
    memory_info =  engines_api.get_system_memory_info #engines_api.get_system_memory_info
    return_json(memory_info)
  rescue StandardError =>e
    log_error(request, e)
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
# @return [Hash]  :one :five :fithteen :running :idle

get '/v0/system/metrics/load' do
  begin
    load_info = engines_api.get_system_load_info
    return_json(load_info)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method get_system_metrics_memory_statistics
# @overload get '/v0/system/metrics/memory/statistics'
# Return memory statistics for all containers
#  services and applications are [Hash]s
#  container_name: Hash [:maximum, :current, :limit]
# @return [Hash] :containers Hash :applications :services

get '/v0/system/metrics/memory/statistics' do
  begin
    memory_statistics = MemoryStatistics.total_memory_statistics(engines_api)
    return_json( memory_statistics)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method get_system_metrics_disk
# @overload get '/v0/system/metrics/disks'
#    1k blocks
# @return [Hash]  :device_name = [Hash]  :type :blocks :used :available :usage :mount
#
get '/v0/system/metrics/disks' do
  begin
    disk_statistics = engines_api.get_disk_statistics
    return_json(disk_statistics)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method get_system_metrics_network
# @overload get '/v0/system/metrics/network'
# @return [Hash] :tx :rx
#
get '/v0/system/metrics/network' do
  begin
    net_statistics = engines_api.get_network_statistics
    return_json(net_statistics)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @!endgroup