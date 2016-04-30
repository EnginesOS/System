get '/v0/system/metrics/memory' do
  memory_info = MemoryStatistics.get_system_memory_info #@@engines_api.get_system_memory_info
  unless memory_info.is_a?(FalseClass)
    return memory_info.to_json
  else
    return log_error(request, memory_info)
  end
end

get '/v0/system/metrics/load' do
  load_info = SystemStatus.get_system_load_info
  unless load_info.is_a?(FalseClass)
    return load_info.to_json
  else
    return log_error(request, load_info)
  end
end

get '/v0/system/metrics/memory/statistics' do
  memory_statistics = MemoryStatistics.total_memory_statistics(@@engines_api)
  unless memory_statistics.is_a?(FalseClass)
    return memory_statistics.to_json
  else
    return log_error(request, memory_statistics)
  end
end

get '/v0/system/metrics/disks' do
  disk_statistics = @@engines_api.get_disk_statistics
  unless disk_statistics.is_a?(FalseClass)
    return disk_statistics.to_json
  else
    return log_error(request, disk_statistics)
  end
end

