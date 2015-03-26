
require "/opt/engines/lib/ruby/containers/objects/DatabaseService.rb"

require_relative "SoftwareService.rb"

class MySQLService < SoftwareService
  
    
#overloaded for the moment
  def add_consumer_to_service(site_hash)
    p :add_consumer
    p site_hash
  
    if site_hash[:variables].has_key?(:name) == false || site_hash[:variables][:name] == nil    
          site_hash[:variables][:name] = site_hash[:variables][:database_name]
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
      if site_hash.has_key?(:service_container_name) == true
      container_name = site_hash[:service_container_name]
    else
      container_name =  site_hash[:variables][:type] + "_server"
    end
      cmd = "docker exec " +  container_name + " /home/createdb.sh " + site_hash[:variables][:database_name] + " " + site_hash[:variables][:db_username] + " " + site_hash[:variables][:db_password]

      #save details with some manager
      SystemUtils.debug_output("Create DB Command",cmd)

      SystemUtils.run_system(cmd)
      
      #FIXME need to checc result from script
      return true
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def drop_database  site_hash
    
    begin
      container_name =  site_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/dropdb.sh " + site_hash[:variables][:database_name] + " " + site_hash[:variables][:db_username] + " " + site_hash[:variables][:db_password]

      #save details with some manager
      SystemUtils.debug_output("Drop DB Command",cmd)

      return run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def get_site_hash(site_hash)
#    site_hash[:type_path] =  site_hash[:service_type]
   
#    site_hash = Hash.new()
#    site_hash[:service_type]='database'
#    site_hash[:name]=database.name
#    site_hash[:flavor]=database.flavor
#    site_hash[:host]=database.dbHost 
#    site_hash[:user]=database.dbUser
#    site_hash[:pass]= database.dbPass
#      #FixME can over write owner in addconsumer need to overide and protect ownership
#    site_hash[:parent_engine]  =  database.owner
#    site_hash[:owner]= database.owner
#    site_hash[:publisher_namespace] = "EnginesSystem"
#       p site_hash
     return site_hash      
    
  end
    
#noop overloads 
 
  def reregister_consumers
        #No Need they are static
  end
end 