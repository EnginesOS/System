require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer_to_service(site_string,engine)
      ip_str = engine.get_ip_str
       return  engine.docker_api.register_dns(engine.hostName,ip_str)
      
    end
    
    def rm_consumer_from_service (site_string,engine)
      ip_str = engine.get_ip_str
       return  engine.docker_api.deregister_dns(engine.hostName,ip_str)
    end
  
end