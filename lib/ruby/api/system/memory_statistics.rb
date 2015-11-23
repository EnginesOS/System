module MemoryStatistics
  def self.collate_containers_mem(mem_stats)
    stats = {}
    stats[:allocated] = mem_stats[:engines][:totals][:allocated] + mem_stats[:services][:totals][:allocated].to_i
    stats[:in_use] = mem_stats[:engines][:totals][:in_use] + mem_stats[:services][:totals][:in_use].to_i
    stats[:peak_sum] = mem_stats[:engines][:totals][:peak_sum] + mem_stats[:services][:totals][:peak_sum].to_i
    stats
  end

  def self.total_memory_statistics(api)
    engines_memory_statistics = {}

    engines = api.getManagedEngines
    services = api.getManagedServices
    # system_services = api.listSystemServices
    engines_memory_statistics[:containers] = {}
    engines_memory_statistics[:containers][:applications] = collect_containers_memory_stats(engines)
    engines_memory_statistics[:containers][:services] = collect_containers_memory_stats(services)
    engines_memory_statistics[:containers][:totals] = {}
    engines_memory_statistics[:containers][:totals][:applications] = engines_memory_statistics[:containers][:applications][:totals]
    engines_memory_statistics[:containers][:totals][:services] = engines_memory_statistics[:containers][:services][:totals]
    engines_memory_statistics[:containers][:applications].delete(:totals)
    engines_memory_statistics[:containers][:services].delete(:totals)
    # engines_memory_statistics[:system_services] = collect_container_memory_stats(system_services)

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
      next if engine.setState != "running"
      container_sym = engine.container_name.to_sym
      mem_stats[container_sym] = self.container_memory_stats(engine)
      mem_stats[:totals][:allocated] += mem_stats[container_sym][:limit].to_i
      mem_stats[:totals][:in_use] += mem_stats[container_sym][:current].to_i
      mem_stats[:totals][:peak_sum] += mem_stats[container_sym][:maximum].to_i
    end
    mem_stats
  end

  def self.container_memory_stats(container)
    ret_val = {}
    if container && container.container_id.nil? || container.container_id == '-1'
      container_id = ContainerStateFiles.read_container_id(container)
    end
    #   return self.empty_container_result  unless container.is_active?

    if container && container.container_id.nil? == false && container.container_id != '-1'
      # path = '/sys/fs/cgroup/memory/docker/' + container.container_id.to_s + '/'
      path = SystemUtils.cgroup_mem_dir(container.container_id.to_s)
      if Dir.exist?(path)
        ret_val.store(:maximum, File.read(path + '/memory.max_usage_in_bytes').to_i)
        ret_val.store(:current, File.read(path + '/memory.usage_in_bytes').to_i)
        ret_val.store(:limit, File.read(path + '/memory.limit_in_bytes').to_i)
      else
        # SystemUtils.log_error_mesg('no_cgroup_file for ' + container.container_name, path)
        ret_val  = self.empty_container_result
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

  def self.empty_container_result
    ret_val = {}
    ret_val.store(:maximum, 0)
    ret_val.store(:current, 0)
    ret_val.store(:limit, 0)
    return ret_val
  end

  def self.avaiable_ram
    mem_stats = self.get_system_memory_info
    swp == 0 
    swp = ret_val[:swap_free] unless  ret_val[:swap_free].nil? 
    swp /= 2 unless swp == 0 
    mem_stats[:free] + mem_stats[:buffers]  + mem_stats[:file_cache] + swp
  end
  def self.get_system_memory_info
    ret_val = {}
    proc_mem_info_file = File.open('/proc/meminfo')
    proc_mem_info_file.each_line do |line|
      values = line.split(' ')
      case values[0]
      when 'MemTotal:'
        ret_val[:total] = values[1].to_i
      when 'MemFree:'
        ret_val[:free] = values[1].to_i
      when 'Buffers:'
        ret_val[:buffers] = values[1].to_i
      when 'Cached:'
        ret_val[:file_cache] = values[1].to_i
      when 'Active:'
        ret_val[:active] = values[1].to_i
      when 'Inactive:'
        ret_val[:inactive] = values[1].to_i
      when 'SwapTotal:'
        ret_val[:swap_total] = values[1].to_i
      when 'SwapFree:'
        ret_val[:swap_free] = values[1].to_i
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
