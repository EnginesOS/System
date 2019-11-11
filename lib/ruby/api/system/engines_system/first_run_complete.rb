module FirstRunComplete
  def first_run_complete(install_mgmt = true)
    unless File.exist?(SystemConfig.FirstRunRan) == true
      first_run = loadManagedService('firstrun')
      Thread.start do
        begin
          first_run.stop_container
          first_run.destroy_container
          FileUtils.touch('/opt/engines/run/system/flags/install_mgmt') if install_mgmt == true
          FileUtils.touch('/opt/engines/run/system/flags/first_run_ready')
        rescue StandardError => e
          STDERR.puts('FIRST RUN Thread Exception' + e.to_s + ':' + e.backtrace.to_s)
        end
      end
    end
    true
  end

  private

  def mark_complete
    FileUtils.touch(SystemConfig.FirstRunRan)
    disable_service('firstrun')
  end
end
