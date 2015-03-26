
require_relative  "../ManagedService.rb"
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
     

    
    def create_hash(engine)
    
    proto ="http https"
    case engine.protocol
    when :https_only
        proto="https"
    when :http_and_https
         proto ="http https"
    when :http_only
          proto="http"
    end
#
#    p :proto 
#    p proto
     
    site_hash = Hash.new()
    site_hash[:variables] = Hash.new
    site_hash[:variables][:parent_engine]=engine.containerName
    site_hash[:variables][:name]=engine.containerName
    site_hash[:service_label] = proto + ":" + engine.fqdn
    site_hash[:variables][:container_type]=engine.ctype
    site_hash[:variables][:fqdn]=engine.fqdn
    site_hash[:variables][:port]=engine.port.to_s
    site_hash[:variables][:proto]= proto
    site_hash[:type_path] = site_hash[:service_type]='nginx'
    site_hash[:publisher_namespace] = "EnginesSystem" 
      SystemUtils.debug_output("create nginx Hash",site_hash)
     return site_hash       
    
  end
    
end 