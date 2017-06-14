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
    if c.is_running?
      return true if is_startup_complete?(c)
      ts =
      inc = 1/(timeout * 4)
      begin
        Timeout::timeout(timeout) do
          sfn = @system_api.container_state_dir(c) + '/run/flags/startup_complete'
          s = 0
          while ! File.exist?(sfn)
            STDERR.puts('Sleep ' + c.container_name)
            sleep 0.25 + s
            s += inc
          end
        end
      rescue Timeout::Error
        return false
      end
      true
    else
      false
    end
  end
end