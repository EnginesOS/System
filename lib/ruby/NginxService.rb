require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class NginxService < ManagedService 
  
  def add_consumer_to_service(site_string)
      return  @docker_api.register_site(site_string) 
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.deregister_site(site_string) 
    end 
     

    
end