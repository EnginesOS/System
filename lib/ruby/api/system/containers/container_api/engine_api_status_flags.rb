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
    sfd = @system_api.container_state_dir(c) +'/run/flags'
    state_file_name = sfd + '/state'
    sfn = sfd + '/startup_complete'
    if c.is_running?
      if is_startup_complete?(c)
        r = true
      else
        begin
          Timeout::timeout(timeout) do
            begin
              require 'rb-inotify'
              notifier = INotify::Notifier.new
              while ! File.exist?(sfn)
                if  File.exist?(state_file_name)
                  notifier.watch(state_file_name, :modify) { next }
                else
                  notifier.watch(sfd, :modify) { next }
                end
                notifier.process
              end
            rescue Exception => e
              STDERR.puts('Select for wait for startup complete raise Exception ' + e.to_s)
              STDERR.puts('Backtrace ' + e.backtrace.to_s)
            end
            r = c.is_running?
          end
        rescue Timeout::Error
          STDERR.puts('Timeout on wait for ' + c.container_name)
          r = File.exist?(sfn)
        end
      end
    end
    r
  end

  def init_container_info_dir(c)
    @system_api.init_container_info_dir(c)
  end
end