require 'securerandom' 
 
class BuilderPublic
def initialize(builder)
 @builder = builder
end
 def engine_name
   @builder.container_name
 end
 def domain_name
   @builder.domain_name
 end
  def fqdn
    @builder.hostname + "." + @builder.domain_name
  end
 def hostname 
   @builder.hostname
 end
 
 def http_protocol  
   if @builder.http_protocol.include?("https")
     return "https"     
   end
   return "http"
 end
 
 def repoName
   @builder.repoName
 end
 def webPort
   @builder.webPort
 end
 def build_name
   @builder.build_name
 end
 def runtime
   @builder.runtime
 end     
 def fqdn
   return @builder.hostname + "." + @builder.domain_name
 end
 def set_environments 
   @builder.set_environments
 end     
 def environments
   @builder.environments
 end
 
 def mysql_host
   return "mysql.engines.internal"
 end
 
 def pqsql_host
   return "pgsql.engines.internal"
 end
 
 
 def blueprint
   return @builder.blueprint
 end
 
 def random cnt
   len = cnt.to_i
   rnd = SecureRandom.hex(len)
#       p :RANDOM__________
#       p rnd.byteslice(0,len) 
   return rnd.byteslice(0,len) 
 end
 
 

end