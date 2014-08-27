require_relative 'Service.rb'

class Database < Service

  def initialize(name,host,user,pass,flavor)
     @serviceType="database"
     @flavor = flavor #mysql pgsql AWS_rdms etc
     @dbHost = host
     @dbUser = user
     @dbPass = pass
     @name = name
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
end