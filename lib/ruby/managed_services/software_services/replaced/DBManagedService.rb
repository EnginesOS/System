require "/opt/engines/lib/ruby/containers/objects/DatabaseService.rb"

require_relative  "ManagedService.rb"

class DBManagedService < ManagedService
  #overloaded for the moment
  def add_consumer_to_service(service_hash)
    p :add_consumer
    p service_hash
    if service_hash.has_key?(:service_handle) == false || service_hash[:service_handle] == nil
      service_hash[:service_handle] = service_hash[:database_name]
    end
    return  create_database(service_hash)
  end

  def rm_consumer_from_service (service_hash)
    return  true
  end

  def create_database  service_hash

    begin
      p :create_db
      p service_hash
      container_name =  service_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/createdb.sh " + service_hash[:database_name] + " " + service_hash[:user] + " " + service_hash[:pass]

      #save details with some manager
      SystemUtils.debug_output("Create DB Command",cmd)

      return SystemUtils.run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  def drop_database  service_hash

    begin
      container_name =  service_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/dropdb.sh " + service_hash[:name] + " " + service_hash[:user] + " " + service_hash[:pass]

      #save details with some manager
      SystemUtils.debug_output("Drop DB cmd",cmd)

      return run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end

  #  def get_service_hash(database)
  #    service_hash = Hash.new()
  #    service_type = service_hash[:service_type]='database'
  #    service_hash[:name]=database.name
  #    service_hash[:flavor]=database.flavor
  #    service_hash[:host]=database.dbHost
  #    service_hash[:user]=database.dbUser
  #    service_hash[:pass]= database.dbPass
  #      #FixME can over write owner in addconsumer need to overide and protect ownership
  #    service_hash[:parent_engine]  =  database.owner
  #    service_hash[:owner]= database.owner
  #    service_hash[:publisher_namespace] = "EnginesSystem"
  #
  #       p service_hash
  #     return service_hash
  #
  #  end

  #  def create_service_hash(database)
  #    service_hash = Hash.new()
  #       service_type = service_hash[:service_type]='database'
  #       service_hash[:name]=database.name
  #       service_hash[:flavor]=database.flavor
  #       service_hash[:host]=database.dbHost
  #       service_hash[:user]=database.dbUser
  #       service_hash[:pass]= database.dbPass
  #         #FixME can over write owner in addconsumer need to overide and protect ownership
  #       service_hash[:parent_engine]  =  database.owner
  #       service_hash[:owner]= database.owner
  #       service_hash[:publisher_namespace] = "EnginesSystem"
  #
  #          p service_hash
  #        return service_hash
  #  end
  #noop overloads

  def reregister_consumers
    #No Need they are static
  end
end 