require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class DNSService < ManagedService 
  

  def get_site_hash(engine)
    site_hash = Hash.new()
    site_hash[:name]=engine.containerName
    site_hash[:container_type]=engine.ctype
    site_hash[:hostname]=engine.hostName
    site_hash[:ip]=engine.get_ip_str.to_s
    return site_hash
      
  end
  
  def add_consumer_to_service(site_hash)
  
      ip_str = site_hash[:ip]
      hostName = site_hash[:hostname]
        puts hostName + " " + ip_str 
      if ip_str.length > 7 #fixme need to check valid ip and that host is valid
       return  @core_api.register_dns(hostName,ip_str)
      else
        return false
      end
      
    end
    
  def rm_consumer_from_service (site_hash)
    hostName = site_hash[:hostname]
    return  @core_api.deregister_dns(hostName)
  end
  
end