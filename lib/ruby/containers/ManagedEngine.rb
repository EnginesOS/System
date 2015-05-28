

class ManagedEngine < ManagedContainer

  
  def initialize(name,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime,core_api,data_uid,data_gid,deployment_type)
                            
                 @last_error="None"                 
                 @container_name=name
                 @memory=memory
                 @hostname=hostname
                 @domain_name=domain_name
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
                 @core_api= core_api
                 @deployment_type = deployment_type
                 
    @ctype ="container"
    @conf_self_start=false
    @data_uid=data_uid
    @data_gid=data_gid
   
    save_state # no config.yaml throws a no such container so save so others can use
    
         end 
         
  attr_reader :ctype, :plugins_path, :extract_plugins

  def plugins_path
    return  "/plugins/"
  end
  
  def extract_plugins
    false
  end

  def attached_services
    @core_api.attached_services(self)
  end
  
  def ManagedEngine.from_yaml( yaml ,core_api )
          managedEngine = YAML::load( yaml )
           if managedEngine == nil ||  managedEngine == false
             return false
           end
    managedEngine.docker_info = nil
          managedEngine.core_api=(core_api)
          return managedEngine
    end
end
  