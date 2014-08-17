require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer(engine)    
    ret_val = @docker_api.register_site(engine)
    if ret_val == false
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
    ret_val = @docker_api.deregister_site(engine)
        if ret_val == false
          return false
        end
    name=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s

     if(@consumers !=  nil || @consumes.length>0)
        @consumers.delete(name)
     end

    save_state
    return true
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