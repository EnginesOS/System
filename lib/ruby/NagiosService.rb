
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"

class NagiosService < ManagedService
  
  def add_consumer(engine)
    site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s    
    result = @docker_api.add_monitor(site_string)
     if result != true
       return result
     end
 
      if @consumers == nil
        @consumers = Array.new
      end
      
      if @consumers.include?(site_string) == false     # only add if doesnt exists but allow register
         @consumers.push(site_string)
      end
    save_state
     return result
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
   
     
  def reregister_consumers
     
     @consumers.each do |site|
       @docker_api.add_monitor(engine)    
     end
  end
end 