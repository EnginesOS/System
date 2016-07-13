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
     STDERR.puts('MGMT SERVICE CREATED ')
   FileUtils.touch(SystemConfig.FirstRunRan)
   r = disable_service('firstrun')
     STDERR.puts('FIRST RUN RETIRED' + r.to_s)
   end
      STDERR.puts('FIRST RUN Thread complete ' + r.to_s)
   
      rescue StandardError => e
         STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
        end
    end
    return true    
   rescue StandardError => e
   STDERR.puts(e.to_s + ':' + e.backtrace.to_s)
      log_exception(e, event_hash)
 end
end