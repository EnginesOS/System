require_relative 'StaticService.rb'

class DatabaseService < StaticService

  def initialize(parent,name,host,user,pass,flavor)
     @serviceType="database"
     @flavor = flavor #mysql pgsql AWS_rdms etc
     @dbHost = host
     @dbUser = user
     @dbPass = pass
     @name = name
     @owner = parent
   end
   
   def owner
     return @owner
   end
   
   def dbHost
     return @dbHost
   end
   
   def dbUser
     return @dbUser
   end
   def dbPass
     return @dbPass
   end
   def flavor
     return @flavor
   end
   def name
     return @name
   end
   
  def add_backup_src_to_hash backup_hash
     backup_hash[:source_type] = flavor
     backup_hash[:source_name] = name
     backup_hash[:source_host] =  dbHost
     backup_hash[:source_user] = dbUser
     backup_hash[:source_pass] = dbPass
             
   end
end