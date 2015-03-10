require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/ContainerObjects/DatabaseService.rb"
require_relative "SoftwareService.rb"


class PgSQLService < SoftwareService

    
#overloaded for the moment
  def add_consumer_to_service(site_hash)
    p :add_consumer
    p site_hash
    if site_hash.has_key?(:name) == false || site_hash[:name] == nil    
          site_hash[:name] = site_hash[:database_name]
      end
    return  create_database(site_hash) 
     end
     
  def rm_consumer_from_service (site_hash)
       return  true
    end 
    

  def create_database  site_hash
    
    begin
      p :create_db
      p site_hash
      container_name =  site_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/createdb.sh " + site_hash[:name] + " " + site_hash[:user] + " " + site_hash[:pass]

      #save details with some manager
      SystemUtils.debug_output(cmd)

      return SystemUtils.run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def drop_database  site_hash
    
    begin
      container_name =  site_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/dropdb.sh " + site_hash[:name] + " " + site_hash[:user] + " " + site_hash[:pass]

      #save details with some manager
      SystemUtils.debug_output(cmd)

      return run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
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
    site_hash[:publisher_namespace] = "EnginesSystem"
       p site_hash
     return site_hash      
    
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 