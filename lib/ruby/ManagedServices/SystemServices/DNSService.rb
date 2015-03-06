require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "../ManagedService.rb"
class DNSService < ManagedService 
  

  def get_site_hash(engine)
    if engine.is_a?(ManagedEngine)   ||    engine.is_a?(ManagedService   )
      site_hash = Hash.new()
      site_hash[:type_path] =  site_hash[:service_type]='dns'
      site_hash[:parent_engine]=engine.containerName
      site_hash[:name]=engine.containerName
      site_hash[:container_type]=engine.ctype
      site_hash[:hostname]=engine.hostName
      site_hash[:ip]=engine.get_ip_str.to_s
      site_hash[:publisher_namespace] = "EnginesSystem"

    else  #was passed a hash
      site_hash=engine
      site_hash[:type_path] =  site_hash[:service_type]
     p :site_hash_pass_toadd_dns
      p site_hash
      engine = @core_api.loadManagedEngine(site_hash[:parent_engine])
      site_hash[:container_type]=engine.ctype
      site_hash[:name]=engine.containerName
        if site_hash.has_key?(:ip) == false
          site_hash[:ip]=engine.get_ip_str.to_s
        end
        if site_hash.has_key?(:hostname) == false
          site_hash[:hostname]=engine.hostName
        elsif site_hash.has_key?(:domain_name)
          site_hash[:hostname] = site_hash[:hostname] + "." + site_hash[:domain_name]
        end      
    end
    
    return site_hash
  end
  
  def add_consumer_to_service(site_hash)
  
      ip_str = site_hash[:ip]
      hostName = site_hash[:hostname]
        puts hostName + " " + ip_str 
      if ip_str.length > 7 #fixme need to check valid ip and that host is valid
       return  @core_api.register_dns(site_hash[:hostname],ip_str)
      else
        return false
      end
      
    end
    
  def rm_consumer_from_service (site_hash)
p :deregister
p site_hash[:name]
    return  @core_api.deregister_dns(site_hash[:hostname])
  end
  
end