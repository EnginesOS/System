module PublicApiSystemMetrics

  require_relative '/opt/engines/lib/ruby/api/system/memory_statistics.rb'
  require_relative '/opt/engines/lib/ruby/api/system/system_status.rb'
  def get_system_memory_info
    @system_api.get_system_memory_info
  rescue StandardError => e
    handle_exception(e)
  end

  def get_system_load_info
    @system_api.get_system_load_info
  rescue StandardError => e
    handle_exception(e)
  end

  def total_memory_statistics()
    MemoryStatistics.total_memory_statistics(@core_api)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_disk_statistics
    @system_api.get_disk_statistics
  rescue StandardError => e
    handle_exception(e)
  end

  def get_network_statistics
    @system_api.get_network_statistics
  rescue StandardError => e
    handle_exception(e)
  end
end