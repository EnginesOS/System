
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require "/opt/engos/lib/ruby/SysConfig.rb"
require "/opt/engos/lib/ruby/ManagedEngine.rb"
require "/opt/engos/lib/ruby/ManagedService.rb"
require "/opt/engos/lib/ruby/NginxService.rb"
require "/opt/engos/lib/ruby/NagiosService.rb"
require "/opt/engos/lib/ruby/EngineBuilder.rb"

class EnginesOSapi
  def initialize()
    @docker_api = Docker.new
  end
  
  def docker_api
    return @docker_api
  end
  
  #hmm something like this to get errors back
  
  class  EnginesOSapiResult
    def initialize(result,code,item_name, msg)
          @was_sucess=result
          @result_code = code
          @item_name = item_name
          @result_mesg = error_msg
      end
      
     def initialize(item_name)
       @was_sucess=true
       @result_code = 0
       @item_name = item_name
       @result_mesg = "OK"
     end
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,domain_name,environment)
    engine = engine_builder.build_from_blue_print
    engine.set_docker_api  docker_api
    engine.save_state
    return engine    
    
  end
 
  
  def getManagedEngines()
         ret_val=Array.new
            Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
              yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"     
              if File.exists?(yfn) == true           
                yf = File.open(yfn)   
                managed_engine = ManagedEngine.from_yaml(yf,@docker_api)          
                if managed_engine                            
                  ret_val.push(managed_engine)
                end
                yf.close
              end
            end
            return ret_val
       end
 
  def getManagedServices()
           ret_val=Array.new
              Dir.entries(SysConfig.CidDir + "/services/").each do |contdir|
                yfn = SysConfig.CidDir + "/services/" + contdir + "/config.yaml"     
                if File.exists?(yfn) == true           
                  yf = File.open(yfn)   
                  managed_service = ManagedService.from_yaml(yf,@docker_api)          
                  if managed_service                            
                    ret_val.push(managed_service)
                  end
                  yf.close
                end
              end
              return ret_val
         end
       
  def loadManagedService(service_name)
 
           managed_service = EnginesOSapi.loadManagedService(service_name,@docker_api)
           
         return managed_service
  end
  def EnginesOSapi.loadManagedService(service_name,docker_api)
      yam_file_name = SysConfig.CidDir + "/services/" + service_name + "/config.yaml"
           
              if File.exists?(yam_file_name) == false
                puts("No such configuration:" + yam_file_name )
                return nil
              end 
              
            yaml_file = File.open(yam_file_name) 
             # managed_service = YAML::load( yaml_file)
             managed_service = ManagedService.from_yaml(yaml_file,docker_api)
             
           return managed_service
    end
  def loadManagedEngine(engine_name)
       yam_file_name = SysConfig.CidDir + "/containers/" + engine_name + "/config.yaml"
      
         if File.exists?(yam_file_name) == false
           puts("No such configuration:" + yam_file_name )
           return nil
         end 
         
       yaml_file = File.open(yam_file_name) 
       managed_engine = ManagedEngine.from_yaml( yaml_file,@docker_api)
      return managed_engine
     end
     
     
 
  
    
#At this stage just wrappers

 
   
   def stopEngine engine_name 
     engine = loadManagedEngine engine_name
     if engine == nil
       return false   
     end  
     return engine.stop_container()     
   end
   
   def startEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false    
     end
     return engine.start_container()     
   end
   
   def pauseEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end    
     return engine.pause_container      
   end
   
   def unpauseEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
     return engine.unpause_container()     
   end
  
    def destroyEngine engine_name
      engine = loadManagedEngine engine_name
      if engine == nil
        return false
      end
      return engine.destroy_container()     
    end
    
   def deleteEngineImage engine_name 
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
    return engine.delete_image()     
   end
    
   def createEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
    return engine.create_container()     
   end
   
   def restartEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
     return engine.restart_container()     
   end
  def registerEngineWebSite engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return false
    end
    return  engine.register_site()     
  end
  
  def deregisterEngineWebSite engine_name
    engine = loadManagedEngine engine_name
      if engine == nil
       return false
      end
   return engine.deregister_site()     
  end
  
   def registerEngineDNS engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
     return  engine.register_dns()     
   end
   
   def deregisterEngineDNS engine_name
     engine = loadManagedEngine engine_name
       if engine == nil
        return false
       end
    return engine.deregister_dns()     
   end
   
   def monitorEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end
     return engine.monitor_site()       
   end
   
   def demonitorEngine engine_name
     engine = loadManagedEngine engine_name
     if engine == nil
       return false
     end         
     return engine.demonitor_site()     
   end
   
   def read_state container
     return container.read_state()
   end

    
    def stopService service_name
      service = loadManagedService(service_name)
      if service == nil
        return false
      end      
      return service.stop_container()        
    end
    
    def startService service_name
      service = loadManagedService(service_name)
            if service == nil
              return false
            end      
            return service.start_container()    
    end
    
    def  pauseService service_name
      service = loadManagedService(service_name)
            if service == nil
              return false
            end      
            return service.pause_container()     
    end
    
    def  unpauseService service_name
      service = loadManagedService(service_name)
             if service == nil
               return false
             end      
        return service.unpause_container()      
    end
    
     def registerServiceWebSite service_name
       service = loadManagedService(service_name)
               if service == nil
                 return false
               end      
          return service.register_site()    
     end
     
    def deregisterServiceWebSite service_name
      service = loadManagedService(service_name)
           if service == nil
               return false
            end      
        return service.deregister_site()     
    end
  def registerServiceDNS service_name
    service = loadManagedService(service_name)
            if service == nil
              return false
            end      
       return service.register_dns()    
  end
  
 def deregisterServiceDNS service_name
   service = loadManagedService(service_name)
        if service == nil
            return false
         end      
     return service.deregister_dns()     
 end 
    def createService service_name
      service = loadManagedService(service_name)
           if service == nil
               return false
            end      
        return service.create_service()
    end
    
    def recreateService service_name
      service = loadManagedService(service_name)
           if service == nil
               return false
            end      
        return service.recreate()      
    end
end
