module EngineApiStatusFlags
  def restart_required?(container)
    File.exist?(@system_api.restart_flag_file(container))
  end

  def rebuild_required?(container)
    File.exist?(@system_api.rebuild_flag_file(container))
  end

  def restart_reason(container)
    if File.exist?(@system_api.restart_flag_file(container))
      File.read(@system_api.restart_flag_file(container))
    else
      false
    end
  end

  def rebuild_reason(container)
    if File.exist?(@system_api.rebuild_flag_file(container))
      File.read(@system_api.restart_flag_file(container))
    else
      false
    end
  end

  def is_startup_complete?(container)
    clear_error
    @system_api.is_startup_complete?(container)
  end

  def wait_for_startup(c, timeout = 5)
    r = false
    state_file_name = @system_api.container_state_dir(c) +'/run/flags/state'
    if ! File.exist?(@system_api.container_state_dir(c) +'/run/flags')
      FileUtils.mkdir_p(@system_api.container_state_dir(c) +'/run/flags')
    end
    if ! File.exist?(state_file_name)
      FileUtils.touch(state_file_name)
    end
    if c.is_running?
      if is_startup_complete?(c)
        r = true
      else
        begin
          Timeout::timeout(timeout) do
            sfn = @system_api.container_state_dir(c) + '/run/flags/startup_complete'
            begin
              require 'rb-inotify'
              notifier = INotify::Notifier.new
              while ! File.exist?(sfn)
                notifier.watch(state_file_name, :modify) {  next }
                notifier.process
                return false unless c.is_running?
              end
            rescue Exception => e
              STDERR.puts('Select for wait for startup complete raise Exception ' + e.to_s)
            end
            r = true
          end
        rescue Timeout::Error
          r = false
        end
      end
    end
    r
  end

  def write_info_tree(c)
    @system_api.write_info_tree(c)
  end
end