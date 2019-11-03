module EngineApiStatusFlags

  def wait_for_startup(c, timeout = 5)
    r = false
    sfd = ContainerStateFiles.container_rflag_dir(c.store_address)
    unless Dir.exist?(sfd)
      FileUtils.mkdir_p(sfd)
    end
    state_file_name = "#{sfd}/state"
    sfn = "#{sfd}/startup_complete"
    if c.is_running?
      if is_startup_complete?(c.store_address)
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
              STDERR.puts('Select for wait for startup complete raise Exception ' + c.container_name.to_s + "\n" + + e.to_s)
              # STDERR.puts('Backtrace ' + e.backtrace.to_s)
            end
            r = c.is_running?
          end
        rescue Timeout::Error
          STDERR.puts('Timeout on wait for ' + sfn)
          r = File.exist?(sfn)
        end
      end
    end
    r
  end

end