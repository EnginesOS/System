module FirstRunComplete
  def first_run_complete(install_mgmt = true)
    return true if File.exist?(SystemConfig.FirstRunRan) == true
    first_run = @engines_api.loadManagedService('firstrun')
    return first_run if first_run.is_a?(EnginesError)
    Thread.start do
      begin
        first_run.stop_container
        first_run.destroy_container
        unless install_mgmt == true
          mark_complete
        else
          mgmt = @engines_api.loadManagedService('mgmt')
          mark_complete unless mgmt.create_service.is_a?(EnginesError)
        end
      rescue StandardError => e
        STDERR.puts('FIRST RUN Thread Exception' + e.to_s + ':' + e.backtrace.to_s)
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