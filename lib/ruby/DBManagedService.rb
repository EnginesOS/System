require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/DatabaseService.rb"
class DBManagedService < ManagedService
  
  def add_consumer_to_service(site_string)
      return  @docker_api.add_monitor(site_string)
     end
  def rm_consumer_from_service (site_string)
       return  @docker_api.rm_monitor(site_string)
    end 
    
#overload
  def get_site_string(database)
    return database.flavor + ":" + database.dbUser + ":" + database.dbPass + "@" + database.dbHost + "/" + database.name
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 