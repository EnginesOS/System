module PublicApiSystemMetrics
  
  require_relative '/opt/engines/lib/ruby/api/system/memory_statistics.rb'
  require_relative '/opt/engines/lib/ruby/api/system/system_status.rb'
  
  def get_system_memory_info
  MemoryStatistics.get_system_memory_info
  end
  
  def get_system_load_info
   SystemStatus.get_system_load_info
  end
  
  def total_memory_statistics()
   MemoryStatistics.total_memory_statistics(@core_api)
  end
  
  def get_disk_statistics
    @core_api.get_disk_statistics
  end
  
end