
require_relative  "../ManagedService.rb"
class DNSService < ManagedService 
  
#
#  def get_site_hash(site_hash)
#    if site_hash.is_a?(Hash)          
#      return site_hash
#    else
#      site_hash = create_site_hash(site_hash)
#    end
#    
#    return site_hash
#  end
  
  def create_site_hash engine
    p :new_Site_has_for 
    p engine
    site_hash = Hash.new()
    site_hash[:type_path] =  site_hash[:service_type]='dns'
    site_hash[:variables] = Hash.new
    site_hash[:variables][:parent_engine]=engine.containerName
      
    site_hash[:variables][:name]=engine.containerName
    site_hash[:variables][:container_type]=engine.ctype
    site_hash[:variables][:hostname]=engine.hostName
    site_hash[:variables][:ip]=engine.get_ip_str.to_s
    site_hash[:publisher_namespace] = "EnginesSystem"
    site_hash[:service_handle]=engine.hostName
      
      return site_hash
  end
  
  def get_site_hash site_hash
    site_hash = super 
     if site_hash[:variables].has_key?(:ip) == false 
       site_hash[:variables][:ip] = SystemUtils.get_system_ip
     end
  end
  
  
  def add_consumer_to_service(site_hash)
  
      ip_str = site_hash[:variables][:ip]
      hostName = site_hash[:variables][:hostname]
        puts hostName 
          p ip_str 
      if ip_str != nil && ip_str.length > 7 #fixme need to check valid ip and that host is valid
       return  @core_api.register_dns(site_hash[:variables][:hostname],ip_str)
      else
        return false
      end
      
    end
    
  def rm_consumer_from_service (site_hash)
    if site_hash == nil
      return false
    end
p :deregister
    p site_hash[:variables][:name]
    return  @core_api.deregister_dns(site_hash[:variables][:hostname])
  end
  
end