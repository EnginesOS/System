module EngineApiStatusFlags
  def restart_required?(container)
    File.exist?(@system_api.restart_flag_file(container))
  end

  def rebuild_required?(container)
    File.exist?(@system_api.rebuild_flag_file(container))
  end

  def restart_reason(container)
    return false unless File.exist?(@system_api.restart_flag_file(container))
    File.read(@system_api.restart_flag_file(container))
  end

  def rebuild_reason(container)
    return false unless File.exist?(@system_api.rebuild_flag_file(container))
    File.read(@system_api.restart_flag_file(container))
  end

  def is_startup_complete?(container)
    clear_error
    @system_api.is_startup_complete?(container)
  end
 
  def wait_for_startup(c, timeout = 5)
  wait_for(c, 'start', timeout)
  return true if is_startup_complete?(c)
   sfn = @system_api.container_state_dir(c) + '/run/flags/startup_complete'
   sf =  IO.open(sfn)
  while ! File.exist?(sfn)
    STDERR.puts(' SELECT ON ' + sfn)
    IO.select(sf)
  end
  sf.close
  true
  ensure
    sf.close unless sf.nil?
  end
end