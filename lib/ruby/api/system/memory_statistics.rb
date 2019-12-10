module MemoryStatistics
  class << self
    def collate_containers_mem(mem_stats)
      {
        allocated: mem_stats[:engines][:totals][:allocated] + mem_stats[:services][:totals][:allocated].to_i,
        in_use: mem_stats[:engines][:totals][:in_use] + mem_stats[:services][:totals][:in_use].to_i,
        peak_sum: mem_stats[:engines][:totals][:peak_sum] + mem_stats[:services][:totals][:peak_sum].to_i
      }
    end

    def total_memory_statistics(api)
      engines = api.getManagedEngines
      services = api.getManagedServices
      system_services = api.getSystemServices
      services.concat(system_services)
      engines_memory_statistics = {
        containers: {
        applications: collect_containers_memory_stats(engines),
        services: collect_containers_memory_stats(services),
        }
      }
      engines_memory_statistics[:containers][:totals] = {
        applications: engines_memory_statistics[:containers][:applications][:totals],
        services: engines_memory_statistics[:containers][:services][:totals]
      }
      engines_memory_statistics[:containers][:applications].delete(:totals)
      engines_memory_statistics[:containers][:services].delete(:totals)
      engines_memory_statistics
    end

    def collect_containers_memory_stats(containers)
      mem_stats = {
        totals: {
        allocated: 0,
        in_use: 0,
        peak_sum: 0
        }
      }
      containers.each do | c|
        next if c.set_state != :running
        container_sym = c.container_name.to_sym
        mem_stats[container_sym] = container_memory_stats(c)
        next unless c.is_running?
        mem_stats[:totals][:allocated] += mem_stats[container_sym][:limit].to_i
        mem_stats[:totals][:in_use] += mem_stats[container_sym][:current].to_i
        mem_stats[:totals][:peak_sum] += mem_stats[container_sym][:maximum].to_i
      end
      mem_stats
    end

    def container_memory_stats(c)
      STDERR.puts "MEM" * 10
      STDERR.puts(" Mem stats for #{c}")
      unless c.is_active?
        empty_container_result(c)
      else
        unless c.id.nil?
          path = SystemUtils.cgroup_mem_dir("#{c.id}")
          STDERR.puts(" Mem stats file #{path}")
          if Dir.exist?(path)
            {
              maximum: File.read("#{path}/memory.max_usage_in_bytes").to_i,
              current: File.read("#{path}/memory.usage_in_bytes").to_i,
              limit: File.read("#{path}/memory.limit_in_bytes").to_i
            }
          else
            STDERR.puts('no_cgroup_file for ' + c.container_name + ':' + path.to_s, path)
            SystemUtils.log_error_mesg('no_cgroup_file for ' + c.container_name + ':' + path.to_s, path)
            empty_container_result(c)
          end
        end
      end
    rescue StandardError => e
      SystemUtils.log_exception(e)
      {
        maximum: e.to_s,
        current: 0,
        limit: container.memory.to_i * 1024 * 1024
      }
    end

    def empty_container_result(container)
      {
        maximum: 0,
        current: 0,
        limit: container.memory.to_i * 1024 * 1024
      }
    end

    def available_ram
      mem_stats = get_system_memory_info
      swp = 0
      swp = mem_stats[:swap_free] unless mem_stats[:swap_free].nil?
      swp /= 2 unless swp == 0
      (mem_stats[:free] + mem_stats[:file_cache] + swp ) / 1024
    end
  end
end
