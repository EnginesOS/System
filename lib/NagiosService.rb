
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"

class NagiosService < ManagedService
  
  def add_consumer(engine)   
    result = @docker_api.add_monitor(engine)
     if result == false
       return false
     end
    name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s  
      if @consumers == nil
        @consumers = Array.new
      end
      
      if @consumers.include?(name) == false     # only add if doesnt exists but allow register
         @consumers.push(name)
      end
    save_state
     return true
   end
   
   def remove_consumer engine
     result = @docker_api.rm_monitor(engine)
     if result == false
           return false
         end
     name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s   
     if(@consumers !=  nil || @consumes.length>0)
            @consumers.delete(name)
         end    
     save_state
     return true
   end
   
   def recreate
     recreate_container
     reregister_consumers
     #need to register sites here
   end
     
  def reregister_consumers
     
     @consumers.each do |site|
       ssh_cmd=SysConfig.addSiteMonitorCmd  +  " \"" + site + " \"" 
       system(ssh_cmd)
       puts ssh_cmd
     end
  end
end 