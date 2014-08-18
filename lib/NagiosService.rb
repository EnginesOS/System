
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"

class NagiosService < ManagedService
  
  def add_consumer(engine)
    site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s    
    result = @docker_api.add_monitor(site_string)
     if result == false
       return false
     end
 
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
     site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s   
     result = @docker_api.rm_monitor(site_string)
    
     if(@consumers !=  nil || @consumes.length>0)
            @consumers.delete(site_string)
         end    
     save_state
     return result
   end
   
   def recreate
     recreate_container
     reregister_consumers
     #need to register sites here
   end
     
  def reregister_consumers
     
     @consumers.each do |site|
       @docker_api.add_monitor(engine)    
     end
  end
end 