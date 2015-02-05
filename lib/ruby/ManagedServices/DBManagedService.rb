require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/ContainerObjects/DatabaseService.rb"
require_relative  "ManagedService.rb"

class DBManagedService < ManagedService

    
#overloaded for the moment
  def add_consumer_to_service(site_hash)
    p site_hash
    if site_hash.has_key?(:name) == false || site_hash[:name] = nil    
          site_hash[:name] = site_hash[:database_name]
      end
    return  @core_api.create_database(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  true
    end 
    

  def get_site_hash(database)
    site_hash = Hash.new()
    site_hash[:service_type]='database'
    site_hash[:name]=database.name
    site_hash[:flavor]=database.flavor
    site_hash[:host]=database.dbHost 
    site_hash[:user]=database.dbUser
    site_hash[:pass]= database.dbPass
      #FixME can over write owner in addconsumer need to overide and protect ownership
    site_hash[:parent_engine]  =  database.owner
    site_hash[:owner]= database.owner
    site_hash[:service_provider] = "EnginesSystem"
       p site_hash
     return site_hash      
    
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 