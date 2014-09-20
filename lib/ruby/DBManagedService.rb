require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/DatabaseService.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
class DBManagedService < ManagedService

    
#overloaded for the moment
  def add_consumer_to_service(site_string)
      return true
     end
  def rm_consumer_from_service (site_string)
       return  true
    end 
    

  def get_site_string(database)
    return database.flavor + ":" + database.dbUser + ":" + database.dbPass + "@" + database.dbHost + "/" + database.name
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 