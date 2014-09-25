
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"

class NagiosService < ManagedService
  
  def add_consumer_to_service(site_string)
      return  @docker_api.add_monitor(site_string)
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.rm_monitor(site_string)
    end 
 
  def get_site_string(engine)
    return engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s      
  end
  
end 