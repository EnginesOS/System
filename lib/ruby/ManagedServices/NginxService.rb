require "/opt/engos/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer_to_service(site_hash)
    puts "add"
    p  site_hash      
      return  @docker_api.register_site(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
    puts "rm"
    p  site_hash      
       return  @docker_api.deregister_site(site_hash) 
    end 
     
  
  def get_site_hash(engine)
 
    if engine.https_only
      proto="https"
    elsif engine.http_and_https
      proto="http https"
    else
      proto="http"
    end
    site_hash = Hash.new()
     site_hash[:name]=engine.containerName
     site_hash[:container_type]=engine.ctype
     site_hash[:fqdn]=engine.fqdn
     site_hash[:port]=engine.port.to_s
     site_hash[:proto]= proto
  
     return site_hash       
    
  end
    
end 