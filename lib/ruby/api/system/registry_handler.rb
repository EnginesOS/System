class RegistryHandler < ErrorsApi
  
   def initialize(system_api)
     @system_api = system_api   
     @registry_ip = false
   end
   
   # FIXME: take out or get_registry ip ..
   def start
     @registry_ip = false
     get_registry_ip
   end
   
  def force_registry_restart
      # start in thread in case timeout clobbers
    @registry_ip = false
    log_error_mesg("Forcing registry restart", nil)
      registry_service = @system_api.loadSystemService('registry')
     return log_error_mesg("PANIC cannot load resgitry service definition", registry_service) unless registry_service.is_a?(SystemService)
#      restart_thread = Thread.new {
        registry_service.stop_container
        registry_service.start_container
        wait = 0
        while registry_service.is_startup_complete? == false
          sleep 1
          wait += 1
          p :wait_for_start
          return force_recreate if wait > 120
        end
        p :restarted_registry
#      }
#      restart_thread.join
      return true
    rescue StandardError => e
      log_exception(e)
    end
  
    def get_registry_ip
      return @registry_ip unless @registry_ip.is_a?(FalseClass)
      registry_service = @system_api.loadSystemService('registry') # FIXME: Panic if this fails
      state = registry_service.read_state
      if state == "running"  
         @registry_ip  = registry_service.get_ip_str 
        return  @registry_ip 
      end
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

#       ip_str = registry_service.get_ip_str
#       return ip_str if ip_str.is_a?(String)
     
      while !registry_service.is_startup_complete?
        sleep 1
        wait += 1
        p :wait_for_start_up
        break if wait > 5
      end
      p :registry_is_up
      return registry_service.get_ip_str
    rescue StandardError => e
      log_exception(e)
    end   
   
    
    private    
    
  def force_recreate
    log_error_mesg("Forcing registry recreate", nil)
    @registry_ip = false
     registry_service = @system_api.loadSystemService('registry')
     return log_error_mesg('Fatal Unable to Start Registry Service: ',registry_service.last_error ) if !registry_service.forced_recreate
    wait = 0
     while !registry_service.is_startup_complete?
           sleep 1
           wait += 1
           p :recreate_wait
           return false if wait > 60
         end
     return true
   end
end
