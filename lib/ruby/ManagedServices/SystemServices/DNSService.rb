require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "../ManagedService.rb"
class DNSService < ManagedService 
  

  def get_site_hash(engine)
    if engine.is_a?(ManagedEngine)   ||    engine.is_a?(ManagedService   )
      site_hash = Hash.new()
      site_hash[:type_path] =  site_hash[:service_type]='dns'
      site_hash[:variables] = Hash.new
      site_hash[:variables][:parent_engine]=engine.containerName
      site_hash[:variables][:name]=engine.containerName
      site_hash[:variables][:container_type]=engine.ctype
      site_hash[:variables][:hostname]=engine.hostName
      site_hash[:variables][:ip]=engine.get_ip_str.to_s
      site_hash[:publisher_namespace] = "EnginesSystem"

    else  #was passed a hash
      site_hash=engine
      site_hash[:type_path] =  site_hash[:service_type]
     p :site_hash_pass_toadd_dns
      p site_hash
      engine = @core_api.loadManagedEngine(site_hash[:variables][:parent_engine])
      site_hash[:variables][:container_type]=engine.ctype
      site_hash[:variables][:name]=engine.containerName
        if site_hash[:variables].has_key?(:ip) == false
          site_hash[:variables][:ip]=engine.get_ip_str.to_s
        end
        if site_hash[:variables].has_key?(:hostname) == false
          site_hash[:variables][:hostname]=engine.hostName
        elsif site_hash[:variables].has_key?(:domain_name)
          site_hash[:variables][:hostname] = site_hash[:variables][:hostname] + "." + site_hash[:variables][:domain_name]
        end      
    end
    
    return site_hash
  end
  
  def add_consumer_to_service(site_hash)
  
      ip_str = site_hash[:variables][:ip]
      hostName = site_hash[:variables][:hostname]
        puts hostName + " " + ip_str 
      if ip_str.length > 7 #fixme need to check valid ip and that host is valid
       return  @core_api.register_dns(site_hash[:variables][:hostname],ip_str)
      else
        return false
      end
      
    end
    
  def rm_consumer_from_service (site_hash)
p :deregister
p site_hash[:variables][:name]
    return  @core_api.deregister_dns(site_hash[:variables][:hostname])
  end
  
end