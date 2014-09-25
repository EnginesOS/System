require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/DatabaseService.rb"
require_relative  "ManagedService.rb"

class DBManagedService < ManagedService

    
#overloaded for the moment
  def add_consumer_to_service(site_hash)
    return  @docker_api.create_database(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  true
    end 
    

  def get_site_hash(database)
    site_hash = Hash.new()
     site_hash["name"]=database.name
     site_hash["flavor"]=database.flavor
     site_hash["host"]=database.dbHost 
     site_hash["user"]=database.dbUser
     site_hash["pass"]= database.dbPass
     return site_hash      
    
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 