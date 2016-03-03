module RunningContainerStatistics
  def stats
    expire_engine_info
    
    return false unless docker_info.is_a?(Hash)
    return false unless docker_info['State'].is_a?(Hash)
    started = docker_info['State']['StartedAt']
    stopped = docker_info['State']['FinishedAt']
    ps_json = ps_container
    SystemDebug.debug(SystemDebug.containers,'ps_container json result',container.container_name,ps_json)
    cpu_time =[0,0,0]
    vss = 0
    rss = 0  
    cpu = 0
  
    return ContainerStatistics.new(read_state, pcnt, started, stopped, rss, vss, cpu) if ps_json.nil?
    ps_json =  ps_json[0] unless ps_json.is_a?(Hash)
    processes = ps_json["Processes"]
    pcnt  = processes.count
    ps_json["Processes"].each do |process|
      vss += process[4]
      rss += process[5]
      time_f = process[9]
      cpu_time = add_time(cpu_time, time_f)
    end
#    ps_lines = ps_container
#    pnt 
#    pcnt = -1
#    rss = 0
#    vss = 0
#    h = m = s = 0
#    ps_lines.each_line.each do |line|
#      if pcnt > 0 # skip the fist line with is a header
#        fields = line.split  #  [6]rss [10] time
#        if fields.nil? == false && fields.count >11
#          rss += fields[7].to_i
#          vss += fields[6].to_i
#          time_f = fields[11]
#          next if time_f.nil?
#          c_HMS = time_f.split(':')
#          if c_HMS.length == 3
#            h += c_HMS[0].to_i
#            m += c_HMS[1].to_i
#            s += c_HMS[2].to_i
#          else
#            m += c_HMS[0].to_i
#            s += c_HMS[1].to_i
#          end
#        end
#      end
#      pcnt += 1
#    end
    cpu = 3600 * cpu_time[2] + 60 * cpu_time[1] + cpu_time[0]
    statistics = ContainerStatistics.new(read_state, pcnt, started, stopped, rss, vss, cpu)
    statistics
  rescue => e
    log_exception(e)
  end

  def get_container_memory_stats()
    @container_api.get_container_memory_stats(self)
  end

  def get_container_network_metrics()
    @container_api.get_container_network_metrics(self)
  end

  private 
  def add_time(cpu_time, time_field)
c_HMS = time_f.split(':')
h = 0
m = 0
s = 0
          if c_HMS.length == 3
            h += c_HMS[0].to_i
            m += c_HMS[1].to_i
            s += c_HMS[2].to_i
          elsif c_HMS.length == 2
            m += c_HMS[0].to_i
            s += c_HMS[1].to_i
          else
            s += c_HMS[0].to_i
          end
      cpu_time[0] += s
      cpu_time[1] += m
      cpu_time[2] += h
      return cpu_time
end
end