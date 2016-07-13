module FirstRunComplete
  
 def first_run_complete
       return true if File.exist?(SystemConfig.FirstRunRan) == true
       r = false
    first_run = @engines_api.getManagedService('firstrun')
    return first_run if first_run.is_a?(EnginesError)
    
   return r if ( r = first_run.stop).is_a?(EnginesError)
   return r if ( r = first_run.destroy).is_a?(EnginesError)
   
   mgmt = @engines_api.getManagedService('mgmt')
   return r if ( r = mgmt.create).is_a?(EnginesError)
   if (r = mgmt.start) == true
   File.delete(SystemConfig.FirstRunRan)
   disable_service('firstrun')
   return true
   end
   return r
 end
end