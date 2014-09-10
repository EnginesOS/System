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



  class  EnginesOSapiResult
    
    def initialize(item_name,cmd)
        @was_sucess=true
        @result_code = 0
        @item_name = item_name      
        @result_mesg = "OK"
        @action = cmd
      end
      
    def initialize(result,code,item_name, msg,cmd)
      @was_sucess=result
      @result_code = code
      @item_name = item_name
      @result_mesg = msg
      @action = cmd
    end

  
    
    def was_sucess
      return @was_sucess
    end
    def result_code
      return @result_code
    end
    def item_name
      return @item_name
    end
    def result_mesg
      return @result_mesg
    end
    def action
      return @action
    end
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,domain_name,environment, @docker_api)
    engine = engine_builder.build_from_blue_print
      if engine != nil
        engine.save_state
        return engine
      end
      return false #FIXME needs to return error object

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
   
  def EnginesOSapi.loadManagedService(service_name,docker_api)
     yam_file_name = SysConfig.CidDir + "/services/" + service_name + "/config.yaml"
 
     if File.exists?(yam_file_name) == false
       return failed(yam_file_name,"No such configuration:","Load Service")
     end
 
     yaml_file = File.open(yam_file_name)
     # managed_service = YAML::load( yaml_file)
     managed_service = ManagedService.from_yaml(yaml_file,docker_api)
     if managed_service == nil
       return failed(yam_file_name,"Fail to Load configuration:","Load Service")
     end
     return managed_service
   end

  def getManagedService(service_name)

    managed_service = EnginesOSapi.loadManagedService(service_name,@docker_api)
    if managed_service == nil
      return failed(service_name,"Fail to Load configuration:","Load Service")
    end
    return managed_service
  end

 
  def loadManagedEngine(engine_name)
    yam_file_name = SysConfig.CidDir + "/containers/" + engine_name + "/config.yaml"

    if File.exists?(yam_file_name) == false
      return failed(yam_file_name,"No such configuration:","Load Engine")
    end

    yaml_file = File.open(yam_file_name)
    managed_engine = ManagedEngine.from_yaml( yaml_file,@docker_api)
      if(managed_engine == nil)
        return failed(yam_file_name,"Failed to Load configuration:","Load Engine")
      end
    return managed_engine
  end

  def recreateEngine engine_name
    engine = loadManagedEngine engine_name
        if engine == nil
          return failed(engine_name,"no Engine","Stop")
        end
        retval = engine.recreate_container()
        if retval == false
          return failed(engine_name,"No Engine","Stop")
        else
          return sucess(engine_name,"Stop")
        end
  end
  #At this stage just wrappers

  def stopEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Stop")
    end
    retval = engine.stop_container()
    if retval == false
      return failed(engine_name,"No Engine","Stop")
    else
      return sucess(engine_name,"Stop")
    end
  end

  def startEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Start")
    end

    retval =  engine.start_container()

    if retval == false
      return failed(engine_name,engine.last_error,"Start")
    end
    if engine.conf_register_site == true
      engine.register_site
    end
    return sucess(engine_name,"Start")

  end

  def pauseEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Pause")
    end

    retval = engine.pause_container

    if retval == false
      return failed(engine_name,engine.last_error,"Pause")
    end
    return sucess(engine_name,"Pause")

  end

  def unpauseEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Unpause")
    end
    retval =  engine.unpause_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Unpause")
    end
    return sucess(engine_name,"unpause")

  end

  def destroyEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Destroy")
    end
    retval =   engine.destroy_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Destroy")
    end
    return sucess(engine_name,"Destroy")
  end

  def deleteEngineImage engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Delete")
    end
    retval =   engine.delete_image()
    if retval == false
      return failed(engine_name,engine.last_error,"Delete")
    end
    return sucess(engine_name,"Delete")
  end

  def createEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Create")
    end
    retval =   engine.create_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Create")
    end
    return sucess(engine_name,"Create")
  end

  def restartEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Restart")
    end
    retval =   engine.restart_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Restart")
    end
    return sucess(engine_name,"Restart")
  end

  def registerEngineWebSite engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Register Engine Web Site")
    end
    retval =  engine.register_site()
    if retval == false
      return failed(engine_name,engine.last_error,"Register Engine Web Site")
    end
    return sucess(engine_name,"Register Engine Web Site")
  end

  def deregisterEngineWebSite engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","DeRegister Engine Web Site")
    end
    retval =   engine.deregister_site()
    if retval == false
      return failed(engine_name,engine.last_error,"DeRegister Engine Web Site")
    end
    return sucess(engine_name,"DeRegister Engine Web Site")
  end

  def registerEngineDNS engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Register Engine DNS")
    end
    retval = engine.register_dns()
    if retval == false
      return failed(engine_name,engine.last_error,"Register Engine DNS")
    end
    return sucess(engine_name,"Register Engine DNS")
  end

  def deregisterEngineDNS engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","DeRegister Engine DNS")
    end
    retval = engine.deregister_dns()
    if retval == false
      return failed(engine_name,engine.last_error,"DeRegister Engine DNS")
    end
    return sucess(engine_name,"DeRegister Engine DNS")
  end

  def monitorEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","Monitor Engine") 
    end
    retval engine.monitor_site()
    if retval == false
      return failed(engine_name,engine.last_error,"Monitor Engine")
    end
    return sucess(engine_name,"Monitor Engine")
  end

  def demonitorEngine engine_name
    engine = loadManagedEngine engine_name
    if engine == nil
      return failed(engine_name,"no Engine","DeMonitor Engine")
    end
    retval = engine.demonitor_site()
    if retval == false
      return failed(engine_name,engine.last_error,"DeMonitor Engine")
    end
    return sucess(engine_name,"DeMonitor Engine")
  end

  def read_state container
    retval =   container.read_state()
    if retval == false
      return failed(contain,"Register Service DNS","Failed to ReadState","read state")
    end
    return sucess(container.name,"read state")
  end

  def stopService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Stop Service")
    end
    retval =   service.stop_container()
    if retval == false
      return failed(service_name,service.last_error,"Stop Service")
    end
    return sucess(service_name,"Stop Service")
  end

  def startService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Start Service")
    end
    retval = service.start_container()
    if retval == false
      return failed(service_name,service.last_error,"Start Service")
    end
    return sucess(service_name,"Start Service")
  end

  def  pauseService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Pause Service")
    end
    retval = service.pause_container()
    if retval == false
      return failed(service_name,service.last_error,"Pause Service")
    end
    return sucess(service_name,"Pause Service")
  end


  def  unpauseService service_name
    service = getManagedService(service_name) 
    if service == nil
      return failed(service_name,"No Such Service","Unpause Service")
    end
    retval = service.unpause_container()
    if retval == false
      return failed(service_name,service.last_error,"Unpause Service")
    end
    return sucess(service_name,"Unpause Service")
  end

  def registerServiceWebSite service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Register Service Web")
    end
    retval =   service.register_site()
    if retval == false
      return failed(service_name,service.last_error,"Register Service Web")
    end
    return sucess(service_name,"Register Service Web")
  end

  def deregisterServiceWebSite service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,"No Such Service","Deregister Service Web")
    end
    retval =   service.deregister_site()
    if retval == false
      return failed(service_name,service.last_error,"Deregister Service Web")
    end
    return sucess(service_name,"Deregister Service Web")
  end

  def registerServiceDNS service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Register Service DNS")
    end
    retval =   service.register_dns()
    if retval == false
      return failed(service_name,service.last_error,"Register Service DNS")
    end
    return sucess(service_name,"Register Service DNS")
  end

  def deregisterServiceDNS service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Deregister Service DNS")
    end
    retval =   service.deregister_dns()
    if retval == false
      return failed(service_name,service.last_error,"Deregister Service DNS")
    end
    return sucess(service_name,"Deregister Service DNS")
  end

  def createService service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Create Service")
    end
    retval =   service.create_service()
    if retval == false
      return failed(service_name,service.last_error,"Create Service")
    end
    return sucess(service_name,"Create Service")
  end

  def recreateService service_name
    service =getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Recreate Service")
    end
    retval =   service.recreate()
    if retval == false
      return failed(service_name,service.last_error,"Recreate Service")
    end
    return sucess(service_name,"Recreate Service")
  end

  protected

  def sucess (item_name ,cmd)
    return  EnginesOSapiResult.new(true,0,item_name, "OK",cmd)
  end

  def failed (item_name,mesg ,cmd)
    return  EnginesOSapiResult.new(false,-1,item_name, mesg,cmd)
  end
end
