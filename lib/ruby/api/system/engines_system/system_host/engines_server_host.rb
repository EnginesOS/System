module EnginesServerHost

  @@server_script_timeout = 15
  def system_image_free_space
    result =   run_server_script('free_docker_lib_space')
    if result[:result] != 0
      result[:result]
    else
      result[:stdout].to_i
    end
  end

  def restart_engines_system_service
    res = Thread.new { run_server_script('restart_system_service') }
    res[:name] = 'restart_system_service'
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    if res.status == 'run'
      true
    else
      raise EnginesException.new(error_hash('Failed recreate_engines_system_service ', res))
    end
  end

  def recreate_engines_system_service
    res = Thread.new { run_server_script('recreate_system_service') }
    res[:name] = 'recreate_system_service'
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    if res.status == 'run'
      true
    else
      raise EnginesException.new(error_hash('Failed recreate_engines_system_service ', res))
    end
  end

  def halt_base_os(reason)
    log_error_mesg("Shutdown Due to:" + reason.to_s)
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
   pthre = Thread.new { run_server_script('power_off_base_os') }
    pthre[:name] = 'power_off_base_os thread'
  end

  def available_ram
    mem_stats = get_system_memory_info
    swp = 0
    swp = mem_stats[:swap_free] unless mem_stats[:swap_free].nil?
    swp /= 2 unless swp == 0
    if mem_stats.key?(:free)  && mem_stats.key?(:file_cache)
      (mem_stats[:free] + mem_stats[:file_cache] + swp ) /1024
    else
      -1
    end
  end
  def  get_system_metrics_summary
    mem_stats = get_system_memory_info
    dstats = get_disk_statistics
    
#    type: values[1],
#    blocks: values[2],
#    used: values[3],
#    available: values[4],
#    usage: values[5],
#    mount: values[6]
    disks = {}
    dstats.each_pair do | key, value|
      disks[key] = {
        mount: value[:mount],
        size: value[:blocks],
        free: value[:available]
    }
    end 
    r = {:"memory" =>
          {"total" => mem_stats[:total].to_i,
           "free"  => mem_stats[:free] ,
           "file" => mem_stats[:file] ,
            "buffers" => mem_stats[:buffers] 
          },
         "disks" => disks
    }
    r
  end
  
  def get_system_memory_info
    # r = run_server_script('memory_stats')
    r = SystemUtils.execute_command('/opt/engines/system/scripts/ssh/memory_stats.sh', false, nil)
    # STDERR.puts( 'get_system_memory_info ' + r.to_s )
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
  end

  def get_network_statistics
    r = run_server_script('network_stats')
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
  end

  def get_disk_statistics
    r= run_server_script('disk_stats')
    stats = r[:stdout]
    lines = stats.split("\n")
    r = {}
    lines.each do |line|
      values = line.split(' ')
      if values.is_a?(Array)
        r[values[0]] = {
          type: values[1],
          blocks: values[2],
          used: values[3],
          available: values[4],
          usage: values[5],
          mount: values[6]
        }
      end
    end
    r
  end

  def run_server_script(script_name , script_data = false, script_timeout = @@server_script_timeout)
    require '/opt/engines/lib/ruby/system/system_config.rb'
    # FIxME
    # use SystemStatus.get_base_host_ip for IP
    unless File.exist?('/var/lib/engines/local_host')
      cmd = 'ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/system/' + script_name + ' engines@' + ENV['CONTROL_IP'] + '  /opt/engines/system/scripts/ssh/' + script_name + '.sh'
    else
      cmd = '/opt/engines/system/scripts/ssh/' + script_name + '.sh'
    end

    # STDERR.puts('RUN SERVER SCRIPT cmd'  + cmd.to_s)
    Timeout.timeout(script_timeout) do
     r = SystemUtils.execute_command(cmd, false, script_data)
     STDERR.puts(' Server Script ' + r.to_s)
     r
      end

  rescue Timeout::Error
    STDERR.puts('Timeout on Running Server Script ' + script_name )
    raise EnginesException.new(error_hash('Timeout on Running Server Script ' + script_name , script_name))
    #system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/system/restart_mgmt engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_mgmt.sh')
  end
end