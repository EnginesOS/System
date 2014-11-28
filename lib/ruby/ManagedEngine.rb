

class ManagedEngine < ManagedContainer

  
  def initialize(name,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime,docker_api,data_uid,data_gid)
                            
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
                 @docker_api= docker_api
    
                 
    @ctype ="container"
    @conf_self_start=false
    @conf_register_dns=true
    @conf_register_site=true
    @conf_monitor_site=false
    @data_uid=data_uid
    @data_gid=data_gid
    
    save_state # no config.yaml throws a no such container so save so others can use
    
         end 
         
  attr_reader :ctype

  def monitored
    return conf_monitor_site
  end
 
  
  def ManagedEngine.from_yaml( yaml ,docker_api )
          managedEngine = YAML::load( yaml )
           if managedEngine == nil ||  managedEngine == false
             return false
           end
          managedEngine.docker_api=(docker_api)
          return managedEngine
    end
end
  