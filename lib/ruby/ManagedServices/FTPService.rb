
require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"

class FTPService < ManagedService
  
  def add_consumer_to_service(site_hash)
      return  @core_api.add_ftp_service(site_hash)
     end
  def rm_consumer_from_service (site_hash)
       return  @core_api.rm_ftp_service(site_hash)
    end 
 

end 