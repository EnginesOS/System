require "/opt/engines/lib/ruby/containers/objects/DatabaseService.rb"

require_relative "SoftwareService.rb"

class MySQLService < SoftwareService
  #overloaded for the moment
  def add_consumer_to_service(service_hash)
    p :add_consumer
    p service_hash

    if service_hash[:variables].has_key?(:name) == false || service_hash[:variables][:name] == nil
      service_hash[:variables][:name] = service_hash[:variables][:database_name]
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
      if service_hash.has_key?(:service_container_name) == true
        container_name = service_hash[:service_container_name]
      else
        container_name =  service_hash[:variables][:type] + "_server"
      end
      cmd = "docker exec " +  container_name + " /home/createdb.sh " + service_hash[:variables][:database_name] + " " + service_hash[:variables][:db_username] + " " + service_hash[:variables][:db_password]

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

  def drop_database  service_hash

    begin
      container_name =  service_hash[:flavor] + "_server"
      cmd = "docker exec " +  container_name + " /home/dropdb.sh " + service_hash[:variables][:database_name] + " " + service_hash[:variables][:db_username] + " " + service_hash[:variables][:db_password]

      #save details with some manager
      SystemUtils.debug_output("Drop DB Command",cmd)

      return run_system(cmd)
    rescue  Exception=>e
      SystemUtils.log_exception(e)
      return false
    end
  end
  #
  #  def get_service_hash(service_hash)
  ##    service_hash[:type_path] =  service_hash[:service_type]
  #
  ##    service_hash = Hash.new()
  ##    service_hash[:service_type]='database'
  ##    service_hash[:name]=database.name
  ##    service_hash[:flavor]=database.flavor
  ##    service_hash[:host]=database.dbHost
  ##    service_hash[:user]=database.dbUser
  ##    service_hash[:pass]= database.dbPass
  ##      #FixME can over write owner in addconsumer need to overide and protect ownership
  ##    service_hash[:parent_engine]  =  database.owner
  ##    service_hash[:owner]= database.owner
  ##    service_hash[:publisher_namespace] = "EnginesSystem"
  ##       p service_hash
  #     return service_hash
  ##
  #  end
  #
  #noop overloads

  def reregister_consumers
    #No Need they are static
  end
end 