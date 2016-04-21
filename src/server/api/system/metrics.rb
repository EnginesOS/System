get '/v0/system/metrics/memory' do
  memory_info = MemoryStatistics.get_system_memory_info #@@core_api.get_system_memory_info
  unless memory_info.is_a?(FalseClass)
    return memory_info.to_json
  else
    return log_error('memory_info')
  end
end

get '/v0/system/metrics/load' do
  load_info = SystemStatus.get_system_load_info
  unless load_info.is_a?(FalseClass)
    return load_info.to_json
  else
    return log_error('load_info')
  end
end

get '/v0/system/metrics/memory/statistics' do
  memory_statistics = MemoryStatistics.total_memory_statistics(@@core_api)
  unless memory_statistics.is_a?(FalseClass)
    return memory_statistics.to_json
  else
    return log_error('memory_statistics')
  end
end

get '/v0/system/metrics/disks' do
  disk_statistics = @@core_api.get_disk_statistics
  unless disk_statistics.is_a?(FalseClass)
    return disk_statistics.to_json
  else
    return log_error('disk_statistics')
  end
end

