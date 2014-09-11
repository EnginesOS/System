require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer(engine)
    site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s    
    ret_val = @docker_api.register_site(site_string)
    if ret_val == false
      return false
    end

     if @consumers == nil
       @consumers = Array.new
     end
     
     if @consumers.include?(site_string) == false     # only add if doesnt exists but allow register
        @consumers.push(site_string)
     end
    save_state
    return ret_val
  end
  
  def remove_consumer engine
    site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s
    ret_val = @docker_api.deregister_site(site_string)
        
#remove from list even if failed to remove from service ?
     if(@consumers !=  nil || @consumes.length>0)
        @consumers.delete(site_string)
     end

    save_state
    return ret_val
  end
  
  def reregister_consumers
    
    @consumers.each do |site_string|
      @docker_api.register_site(site_string)        
    end
  end
  
    
end