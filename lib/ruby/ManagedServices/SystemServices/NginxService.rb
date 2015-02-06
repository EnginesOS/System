require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer_to_service(site_hash)
    puts "add"
    p  site_hash      
      return  @core_api.register_site(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
    puts "rm"
    p  site_hash      
       return  @core_api.deregister_site(site_hash) 
    end 
     
  
  def get_site_hash(engine)
    proto ="http https"
    case engine.protocol
    when :https_only
        proto="https"
    when :http_and_https
         proto ="http https"
    when :http_only
          proto="http"
    end

    p :proto 
    p proto
     
    site_hash = Hash.new()
    site_hash[:parent_engine]=engine.containerName
    site_hash[:name]=engine.containerName
    site_hash[:container_type]=engine.ctype
    site_hash[:fqdn]=engine.fqdn
    site_hash[:port]=engine.port.to_s
    site_hash[:proto]= proto
    site_hash[:service_type]='nginx'
    site_hash[:service_provider] = "EnginesSystem" 
     return site_hash       
    
  end
    
end 