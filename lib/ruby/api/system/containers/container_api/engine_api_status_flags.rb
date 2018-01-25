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
    if c.is_running?
      if is_startup_complete?(c)
        r = true
      else
        inc = 1/(timeout * 4)
        begin
          Timeout::timeout(timeout) do
            sfn = @system_api.container_state_dir(c) + '/run/flags/startup_complete'
            s = 0
            
            begin
              require 'rb-inotify'
              notifier = INotify::Notifier.new             
              STDERR.puts('Select ' + c.container_name)

            while ! File.exist?(sfn)            
              STDERR.puts('Select ' + c.container_name)           
            notifier.watch(sfn, :create) {  next } 
              STDERR.puts('Setup' + c.container_name) 
              notifier.process
              STDERR.puts('Selected' + c.container_name)

             # sleep 0.25 + s
             # s += inc
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
end