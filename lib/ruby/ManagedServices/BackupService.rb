require "/opt/engos/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class BackupService < ManagedService 
  
  
  def add_consumer_to_service(site_hash)
    return  @docker_api.create_backup(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  true
    end 
    
  def get_site_hash(site_hash)
 # called with a hash no need to do anything accept return with arg1
#     
#    site_hash[:name]
#    site_hash[:source_type] #vol|mysql|pgsql|nosql|sys
#    site_hash[:source_name]
#    site_hash[:source_host]
#    site_hash[:source_user]
#    site_hash[:source_pass]
#      
#    site_hash[:dest_proto]
#    site_hash[:dest_port]
#    site_hash[:dest_address]
#    site_hash[:dest_folder]
#    site_hash[:dest_user]
#    site_hash[:dest_pass]
             
    return site_hash       
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end