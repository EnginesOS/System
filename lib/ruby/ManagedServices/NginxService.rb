require "/opt/engos/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer_to_service(site_string)
      return  @docker_api.register_site(site_string) 
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.deregister_site(site_string) 
    end 
     
  
  def get_site_string(engine)
    if engine.https_only
      proto="https"
    elsif engine.http_and_https
      proto="http https"
    else
      proto="http"
    end
    return engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s + ":" + proto     
  end
    
end