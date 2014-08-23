class ManagedEngine < ManagedContainer
  @ctype="container"

  
  def initialize(name,type,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime)
            
                 @ctype =type
                 @last_error="None"
                 
                 @containerName=name
                 @memory=memory
                 @hostName=hostname
                 @domainName=domain_name
                 @image=image
                 @eports=eports 
                 @environments=environments                
                 @volumes=volumes                
                 @port=port                
                 @repo=repo
                 @last_result=""
                 @setState="nocontainer"
                 @databases=dbs
                 @monitored=false
                 @registerSite=true
                 @framework=framework
                 @runtime=runtime
 #FIXME Is this the right place?
    @conf_self_start=false
    @conf_register_dns=false
    @conf_register_site=true
    @conf_monitor_site=false
         
         end 
         
  
  def ctype
    return @ctype    
  end
  
 
  
  def self.from_yaml( yaml ,docker_api )
          managedEngine = YAML::load( yaml )
          managedEngine.set_docker_api(docker_api)
          return managedEngine
    end
end
  