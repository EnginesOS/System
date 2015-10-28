class RegistryHandler < ErrorsApi
  
   def initialize(system_api)
     @system_api = system_api     
   end
   
   # FIXME: take out or get_registry ip ..
   def start
     get_registry_ip
   end
   
  def force_registry_restart
      # start in thread in case timeout clobbers
    log_error_mesg("Forcing registry restart", nil)
      registry_service = @system_api.loadSystemService('registry')
      # FIXME: need to panic if cannot load
      restart_thread = Thread.new {
        registry_service.stop_container
        registry_service.start_container
        while registry_service.is_startup_complete? == false
          sleep 1
          wait += 1
          return force_recreate if wait > 120
        end
      }
      restart_thread.join
      return true
    rescue StandardError => e
      log_exception(e)
    end
  
    def get_registry_ip
      registry_service = @system_api.loadSystemService('registry') # FIXME: Panic if this fails
      state = registry_service.read_state      
        return registry_service.get_ip_str if state == "running"
        log_error_mesg("registry down: " + state.to_s, registry_service)
      case state
      when 'nocontainer'
        registry_service.create_container
      when 'paused'
        registry_service.unpause_container
      when 'stopped'
        registry_service.start_container
      end
      if registry_service.read_state != 'running'
        unless force_recreate
          return log_error_mesg('Fatal Unable to Start Registry Service: ', registry_service.last_error)
        end
      end
      wait = 0

       ip_str = registry_service.get_ip_str
       return ip_str if ip_str.is_a?(String)
       
      while !registry_service.is_startup_complete?
        sleep 1
        wait += 1
        p :wait_for_start_up
        break if wait > 5
      end
      return registry_service.get_ip_str
    rescue StandardError => e
      log_exception(e)
    end   
   
    
    private    
    
  def force_recreate
    log_error_mesg("Forcing registry recreate", nil)
     registry_service = @system_api.loadSystemService('registry')
     return log_error_mesg('Fatal Unable to Start Registry Service: ',registry_service.last_error ) if !registry_service.forced_recreate
    while !registry_service.is_startup_complete?
           sleep 1
           wait += 1
           return false if wait > 60
         end
     return true
   end
end
