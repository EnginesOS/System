
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"

class NagiosService < ManagedService
  
  def add_consumer(engine)   
    name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s
  
    ssh_cmd=SysConfig.addSiteMonitorCmd + " \"" + name + " \"" 
    
      if @consumers == nil
        @consumers = Array.new
      end
      
      if @consumers.include?(name) == false     # only add if doesnt exists but allow register
         @consumers.push(name)
      end
  #FIXME check results
    save_state
     puts ssh_cmd
     return system(ssh_cmd)
   end
   
   def remove_consumer engine
     
     name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s
     ssh_cmd=SysConfig.rmSiteMonitorCmd + " \"" + name + " \"" 
     
     if(@consumers !=  nil || @consumes.length>0)
            @consumers.delete(name)
         end
     #FIXME check results
     save_state
     return system(ssh_cmd)
   end
   
   def recreate
     recreate_container
     reregister_consumers
     #need to register sites here
   end
     
  def reregister_consumers
      sleep(60)
     @consumers.each do |site|
       ssh_cmd=SysConfig.addSiteMonitorCmd  +  " \"" + site + " \"" 
       system(ssh_cmd)
       puts ssh_cmd
     end
  end
end 