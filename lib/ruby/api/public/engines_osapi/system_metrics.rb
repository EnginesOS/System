module SystemMetrics
  def get_system_memory_info
    MemoryStatistics.get_system_memory_info
  rescue StandardError => e
    log_exception_and_fail('get_system_memory_info', e)
  end

  def get_system_load_info
    SystemStatus.get_system_load_info
  rescue StandardError => e
    log_exception_and_fail('get_system_load_info', e)
  end

  def get_memory_statistics
    MemoryStatistics.total_memory_statistics(@core_api)
  end

end