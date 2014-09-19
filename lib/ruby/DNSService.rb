require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class DNSService < ManagedService 
  
  def get_site_string(engine)
   
    return engine.containerName + ":" + engine.fqdn + ":" +     engine.get_ip_str 
  end
  
  def add_consumer_to_service(site_string)
    strings = site_string.split(':')
      ip_str = strings[2]
      hostName = strings[0]
      puts "dns " + site_string
       return  @docker_api.register_dns(hostName,ip_str)
      
    end
    
    def rm_consumer_from_service (site_string)
      strings = site_string.split(':')
      ip_str = strings[2]
          hostName = strings[1]
         
       return  @docker_api.deregister_dns(hostName,ip_str)
    end
  
end