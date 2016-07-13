module FirstRunComplete
  
 def first_run_complete
       return true if File.exist?(SystemConfig.FirstRunRan) == true
       r = false
    first_run = @engines_api.loadManagedService('firstrun')
    return first_run if first_run.is_a?(EnginesError)
    Thread.start do
      begin
  first_run.stop_container
  first_run.destroy_container
   
   mgmt = @engines_api.loadManagedService('mgmt')
    
   unless mgmt.create_service.is_a?(EnginesError)
   
   FileUtils.touch(SystemConfig.FirstRunRan)
   disable_service('firstrun')

   end
    
   
      rescue StandardError => e
         STDERR.puts('FIRST RUN Thread Exception' + e.to_s + ':' + e.backtrace.to_s)
        end
    end
    return true    
   rescue StandardError => e
      log_exception(e, event_hash)
 end
end