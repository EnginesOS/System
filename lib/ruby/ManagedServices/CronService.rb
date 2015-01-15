require "/opt/engines/lib/ruby/ManagedContainer.rb"
require_relative  "ManagedService.rb"
class CronService < ManagedService 
  
  def add_consumer_to_service(site_hash)
    
      return  @core_api.add_cron(site_hash) 
     end
  def rm_consumer_from_service (site_hash)
       return  @core_api.rebuild_crontab(self)  
    end 
     
  def get_site_hash(site_hash)
 
        return site_hash          
   end
   
  #noop overloads 
   
    def reregister_consumers
          #No Need they are static
    end
end
