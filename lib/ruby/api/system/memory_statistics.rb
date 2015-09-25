module MemoryStatistics
  def self.collate_containers_mem(mem_stats)
    stats = {}
    stats[:allocated] = mem_stats[:engines][:allocated] + mem_stats[:services][:allocated]
    stats[:in_use] = mem_stats[:engines][:in_use] + mem_stats[:services][:in_use]
    stats[:peak_sum] = mem_stats[:engines][:peak_sum] + mem_stats[:services][:peak_sum]
    stats
  end

  def self.total_memory_statistics(api)
    engines_memory_statistics = {}
    engines = api.getManagedEngines
    services = api.getManagedServices
    # system_services = api.listSystemServices
    engines_memory_statistics[:engines] = collect_containers_memory_stats(engines)
    engines_memory_statistics[:services] = collect_containers_memory_stats(services)
    # engines_memory_statistics[:system_services] = collect_container_memory_stats(system_services)
    engines_memory_statistics[:containers] = collate_containers_mem(engines_memory_statistics)
    engines_memory_statistics[:system] = self.get_system_memory_info
    engines_memory_statistics
  end

  def self.collect_containers_memory_stats(engines)
    mem_stats = {}
    mem_stats[:totals] = {}
    mem_stats[:totals][:allocated] = 0
    mem_stats[:totals][:in_use] = 0
    mem_stats[:totals][:peak_sum] = 0
    engines.each do | engine|
      mem_stats[:container_name] = self.container_memory_stats(engine)
      mem_stats[:totals][:allocated] += mem_stats[:container_name][:limit]
      mem_stats[:totals][:in_use] += mem_stats[:container_name][:current]
      mem_stats[:totals][:peak_sum] += mem_stats[:container_name][:maximum]
    end
    mem_stats
  end

  def self.container_memory_stats(container)
    ret_val = {}
    if container && container.container_id.nil? || container.container_id == '-1'
      container_id = ContainerStateFiles.read_container_id(container)
    end
    if container && container.container_id.nil? == false && container.container_id != '-1'
      # path = '/sys/fs/cgroup/memory/docker/' + container.container_id.to_s + '/'
      path = SystemUtils.cgroup_mem_dir(container.container_id.to_s)
      if Dir.exist?(path)
        ret_val.store(:maximum, File.read(path + '/memory.max_usage_in_bytes'))
        ret_val.store(:current, File.read(path + '/memory.usage_in_bytes'))
        ret_val.store(:limit, File.read(path + '/memory.limit_in_bytes'))
      else
        SystemUtils.log_error_mesg('no_cgroup_file for ' + container.container_name, path)
        ret_val.store(:maximum, 'No Container')
        ret_val.store(:current, 'No Container')
        ret_val.store(:limit, 'No Container')
      end
    end
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    ret_val.store(:maximum, e.to_s)
    ret_val.store(:current, 'NA')
    ret_val.store(:limit, 'NA')
    return ret_val
  end

  def self.get_system_memory_info
    ret_val = {}
    proc_mem_info_file = File.open('/proc/meminfo')
    proc_mem_info_file.each_line do |line|
      values = line.split(' ')
      case values[0]
      when 'MemTotal:'
        ret_val[:total] = values[1]
      when 'MemFree:'
        ret_val[:free] = values[1]
      when 'Buffers:'
        ret_val[:buffers] = values[1]
      when 'Cached:'
        ret_val[:file_cache] = values[1]
      when 'Active:'
        ret_val[:active] = values[1]
      when 'Inactive:'
        ret_val[:inactive] = values[1]
      when 'SwapTotal:'
        ret_val[:swap_total] = values[1]
      when 'SwapFree:'
        ret_val[:swap_free] = values[1]
      end
    end
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    ret_val[:total] = e.to_s
    ret_val[:free] = -1
    ret_val[:active] = -1
    ret_val[:inactive] = -1
    ret_val[:file_cache] = -1
    ret_val[:buffers] = -1
    ret_val[:swap_total] = -1
    ret_val[:swap_free] = -1
    return ret_val
  end
end
