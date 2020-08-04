class ContainerApi
  def wait_for_startup(c, to = 5)
    r = false
    sfd = ContainerStateFiles.container_rflag_dir(c.store_address)
    wait_for_flag_dir(sfd) unless Dir.exist?(sfd)      
    state_file_name = "#{sfd}/state"
    sfn = "#{sfd}/startup_complete"
    if c.is_running?
      if ContainerStateFiles.is_startup_complete?(c.store_address)
        r = true
      else
        begin
          Timeout::timeout(to) do
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

  def wait_for_flag_dir(sd, to = 5)
    dir = File.dirname(sd)
    require 'rb-inotify' 
    begin
    Timeout::timeout(to) do
    while ! Dir.exist?(sd)
      notifier = INotify::Notifier.new
      notifier.watch(dir, :modify) { next }
      notifier.process
    end
    end
      rescue Timeout::Error
        STDERR.puts('Timeout on wait for ' + sd)
      Dir.exist?(sd)
      end
  end
end
