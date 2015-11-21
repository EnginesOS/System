module RunningContainerStatistics
  
  def stats
      #expire_engine_info
      return false unless docker_info.is_a?(Array)
      return false unless docker_info[0].is_a?(Hash)
      return false unless docker_info[0]['State'].is_a?(Hash)
      started = docker_info[0]['State']['StartedAt']
      stopped = docker_info[0]['State']['FinishedAt']
      ps_container
      pcnt = -1
      rss = 0
      vss = 0
      h = m = s = 0
      @last_result.each_line.each do |line|
        if pcnt > 0 # skip the fist line with is a header
          fields = line.split  #  [6]rss [10] time
          if fields.nil? == false && fields.count >11
            rss += fields[7].to_i
            vss += fields[6].to_i
            time_f = fields[11]
            next if time_f.nil?
            c_HMS = time_f.split(':')
            if c_HMS.length == 3
              h += c_HMS[0].to_i
              m += c_HMS[1].to_i
              s += c_HMS[2].to_i
            else
              m += c_HMS[0].to_i
              s += c_HMS[1].to_i
            end
          end
        end
        pcnt += 1
      end
      cpu = 3600 * h + 60 * m + s
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

end