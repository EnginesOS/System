

require_relative "SoftwareService.rb"

class NagiosService < SoftwareService
  
  def add_consumer_to_service(site_hash)
      return  add_monitor(site_hash)
     end
  def rm_consumer_from_service (site_hash)
       return  rm_monitor(site_hash)
    end 
 

end 