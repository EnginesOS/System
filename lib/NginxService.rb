require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer(engine)    
    name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s
    ssh_cmd=SysConfig.addSiteCmd + " \"" + name +  "\""
     if @consumers == nil
       @consumers = Array.new
     end
     
     if @consumers.include?(name) == false     # only add if doesnt exists but allow register
        @consumers.push(name)
     end
 #FIXME check results
     puts ssh_cmd
    save_state
    return system(ssh_cmd)
  end
  
  def remove_consumer engine
    name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s
    ssh_cmd=SysConfig.rmSiteCmd +  " \"" + name +  "\""
     if(@consumers !=  nil || @consumes.length>0)
        @consumers.delete(name)
     end
    #FIXME check results
    save_state
    return system(ssh_cmd)
  end
  
  def reregister_consumers
     sleep(60)
    @consumers.each do |site|
      ssh_cmd=SysConfig.addSiteCmd +  " \"" + site +  "\""
      system(ssh_cmd)
      puts ssh_cmd
    end
  end
  
    
end