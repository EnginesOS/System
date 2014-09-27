require "/opt/engos/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class BackupService < ManagedService 
  
  
  def add_consumer_to_service(site_hash)
    return  @docker_api.create_database(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  true
    end 
    
  def get_site_hash(object)
    #object is nil Volume | Database
    site_hash = Hash.new()
     
    site_hash[:name]=engine.containerName
    site_hash[:source_type]=engine.ctype #fs|db
    site_hash[:dest_proto]=engine.hostName
    site_hash[:dest_port]=engine.hostName
    site_hash[:dest_address]=engine.get_ip_str.to_s
    site_hash[:dest_folder]=engine.get_ip_str.to_s
    site_hash[:dest_user]=engine.get_ip_str.to_s
    site_hash[:dest_pass]=engine.get_ip_str.to_s
             
    return site_hash       
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end