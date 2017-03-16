module EnginesServerHost

  @@server_script_timeout = 15
  def system_image_free_space
    result =   run_server_script('free_docker_lib_space')
    return result if result.is_a?(EnginesError)
    return -1 if result[:result] != 0
     result[:stdout].to_i
  rescue StandardError => e
    log_exception(e)
    return -1
  end
  
  def restart_engines_system_service
    res = Thread.new { run_server_script('restart_system_service') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
     false
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end
  def recreate_engines_system_service
    res = Thread.new { run_server_script('recreate_system_service') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
     false
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end
  def halt_base_os(reason)
    log_error_mesg("Shutdown Due to:" + reason.to_s)
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
    res = Thread.new { run_server_script('power_off_base_os') }
    rescue StandardError => e
      SystemUtils.log_exception(e)
  end

  def available_ram
    mem_stats = get_system_memory_info
    return mem_stats if mem_stats.is_a?(EnginesError)  
    swp = 0
    swp = mem_stats[:swap_free] unless mem_stats[:swap_free].nil?
    swp /= 2 unless swp == 0
    if mem_stats.key?(:free)  && mem_stats.key?(:file_cache)
    (mem_stats[:free] + mem_stats[:file_cache] + swp ) /1024
    else 
      return -1
    end
  end

  def get_system_memory_info

    r = run_server_script('memory_stats')
    return r if r.is_a?(EnginesError) 
    ret_val = {}
    proc_mem_info = r[:stdout]
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
        return ret_val
      end
      
    end
     ret_val
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
     ret_val
  end

  def get_system_load_info
    ret_val = {}
      r = run_server_script('load_avgs')
    return r if r.is_a?(EnginesError) 
    loadavg_info =r[:stdout]

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
     ret_val
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def get_network_statistics
    r = run_server_script('network_stats')
    return r if r.is_a?(EnginesError) 
    stats = r[:stdout]
    lines = stats.split("\n")
    r = {}
    lines.each do |line|
      values = line.split(' ')
      if values.is_a?(Array)
        r[values[0]] = {}
        r[values[0]][:rx] = values[1]
        r[values[0]][:tx] = values[2]
      end
    end
     r
rescue StandardError => e
  SystemUtils.log_exception(e)
  end

  def get_disk_statistics
    r= run_server_script('disk_stats')
    return r if r.is_a?(EnginesError) 
    stats = r[:stdout]
    lines = stats.split("\n")
    r = {}
    lines.each do |line|
      values = line.split(' ')
      if values.is_a?(Array)
        r[values[0]] = {}
        r[values[0]][:type] = values[1]
        r[values[0]][:blocks] = values[2]
        r[values[0]][:used] = values[3]
        r[values[0]][:available] = values[4]
        r[values[0]][:usage] = values[5]
        r[values[0]][:mount] = values[6]
      end
    end
     r
  end

  def run_server_script(script_name , script_data=false, script_timeout = @@server_script_timeout)
require '/opt/engines/lib/ruby/system/system_config.rb'
# FIxME
# use SystemStatus.get_base_host_ip for IP 
unless File.exist?('/var/lib/engines/local_host')
    cmd = 'ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/' + script_name + ' engines@' + ENV['CONTROL_IP'] + '  /opt/engines/system/scripts/ssh/' + script_name + '.sh'
else
  cmd = '/opt/engines/system/scripts/ssh/' + script_name + '.sh'
end
   
STDERR.puts('RUN SERVER SCRIPT cmd'  + cmd.to_s)      
    Timeout.timeout(script_timeout) do
      return SystemUtils.execute_command(cmd, false, script_data)
    end
  rescue Timeout::Error
    STDERR.puts('Timeout on Running Server Script ' + script_name )
    raise EnginesException.new(error_hash('Timeout on Running Server Script ' + script_name , script_name))
    #system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_mgmt engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_mgmt.sh')
  end

end