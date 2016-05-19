module EnginesServerHost
  def system_image_free_space
    result =   run_server_script('free_docker_lib_space')
    return -1 if result[:result] != 0
    return result[:stdout].to_i
  rescue StandardError => e
    log_exception(e)
    return -1
  end

  def restart_mgmt
    res = Thread.new { run_server_script('restart_mgmt') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
    return false
  end

  def api_shutdown(reason)
    log_error_mesg("Shutdown Due to:" + reason.to_s)
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
    res = Thread.new { run_server_script('halt_system') }
  end

  def get_system_memory_info
    ret_val = {}
    proc_mem_info = run_server_script('memory_stats')[:stdout]
    proc_mem_info.split("\n").each do |line|
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

  def get_system_load_info
    ret_val = {}
    loadavg_info = run_server_script('load_avgs')[:stdout]

    values = loadavg_info.split(' ')
    ret_val[:one] = values[0]
    ret_val[:five] = values[1]
    ret_val[:fifteen] = values[2]
    run_idle = values[3].split('/')
    ret_val[:running] = run_idle[0]
    ret_val[:idle] = run_idle[1]
    ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
    ret_val[:one] = -1
    ret_val[:five] = -1
    ret_val[:fifteen] = -1
    ret_val[:running] = -1
    ret_val[:idle] = -1
    return ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def get_net_statistics
    stats = run_server_script('network_stats')[:stdout]
    lines = stats.split("\n")
    r = {}
    lines.each do
      values = line.split(' ')
      if values.is_a?(Array)
        r[values[0]] = {}
        r[values[0]][:rx] = values[1]
        r[values[0]][:tx] = values[2]
      end
    end
    return r
  end

  def run_server_script(script_name , script_data=false)

    cmd = 'ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/' + script_name + ' engines@' + SystemStatus.get_management_ip + '  /opt/engines/system/scripts/ssh/' + script_name + '.sh'

    SystemUtils.execute_command(cmd, false, script_data)
    #system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_mgmt engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_mgmt.sh')
  rescue StandardError => e
    log_exception(e)
    return -1
  end

end