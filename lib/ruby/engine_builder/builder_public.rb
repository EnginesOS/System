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
   if @builder.http_protocol == nil
     return ""
   end
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

 def set_environments 
   @builder.set_environments
 end     
 def environments
   @builder.environments
 end
 

 
 def blueprint
   return @builder.blueprint
 end

 

end