require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"

require "/opt/engines/lib/ruby/EngineBuilder.rb"
require "/opt/engines/lib/ruby/PermissionRights.rb"
require "/opt/engines/lib/ruby/EnginesOSapiResult.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require "/opt/engines/lib/ruby/prefs/SystemPreferences.rb"
require 'objspace'

class EnginesOSapi
  def initialize()
    @docker_api = Docker.new
  end

  def docker_api
    return @docker_api
  end

  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,domain_name,environment, @docker_api)
    engine = engine_builder.build_from_blue_print
    if engine != nil
      engine.save_state
      return engine
    end
    return  EnginesOSapi.failed(host,"Failed","build_engine") #FIXME needs to return error object

  end
  def build_engine(repository,params)    
    container_name = params[:container_name]
    domain_name = params[:domain_name]
    host_name = params[:host_name]
   evirons = params[:env_variables]
      engine_builder = EngineBuilder.new(repository,host_name,domain_name,evirons, @docker_api)
      engine = engine_builder.build_from_blue_print
      if engine != nil
        engine.save_state
        return engine
      end
      return EnginesOSapi.failed(host,"Failed","build_engine") #FIXME needs to return error object
  
    end
  def getManagedEngines()
    ret_val=Array.new
    Dir.entries(SysConfig.CidDir + "/containers/").each do |contdir|
      yfn = SysConfig.CidDir + "/containers/" + contdir + "/config.yaml"       
      if File.exists?(yfn) == true       
        managed_engine = loadManagedEngine(contdir)
        if managed_engine.is_a?(ManagedEngine)
          ret_val.push(managed_engine)
        else
          puts "failed to load " + yfn 
          p     managed_engine     
        end
      end
    end
#   # puts("engineapi usage")
#    p ObjectSpace.memsize_of(self)
#    puts("engines usage")
#    p ObjectSpace.memsize_of(ret_val)
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
#    puts("engineapi usage")
#    p ObjectSpace.memsize_of(self)
#    puts("servicess usage")
#    p ObjectSpace.memsize_of(ret_val)
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
#
#    puts("engineapi (total) usage")
#    p ObjectSpace.reachable_objects_from(self)
#    puts("service (total) usage")
#    p ObjectSpace.reachable_objects_from(managed_service)
    return managed_service
  end

  def getManagedService(service_name)

    managed_service = EnginesOSapi.loadManagedService(service_name,@docker_api)
    #  if managed_service == nil
    #   return failed(service_name,"Fail to Load configuration:","Load Service")
    #end
    return managed_service
  end

  def loadManagedEngine(engine_name)
    yam_file_name = SysConfig.CidDir + "/containers/" + engine_name + "/config.yaml"

    if File.exists?(yam_file_name) == false
      return failed(yam_file_name,"No such configuration:","Load Engine")
    end

    yaml_file = File.open(yam_file_name)
    managed_engine = ManagedEngine.from_yaml( yaml_file,@docker_api)
    if(managed_engine == nil || managed_engine == false)
      return failed(yam_file_name,"Failed to Load configuration:","Load Engine")
    end
    return managed_engine
  end
  
  def backup_volume(backup_name,engine_name,volume_name,dest_hash)
    engine = loadManagedEngine engine_name
      if engine.is_a?(EnginesOSapiResult)
        return engine
      end
   
      backup_hash = dest_hash
      backup_hash.store(:name, backup_name)
    backup_hash.store(:engine_name, engine_name)
    backup_hash.store(:backup_type, "fs")
      engine.volumes.each do |volume|
        if volume.name == volume_name
          volume.add_backup_src_to_hash(backup_hash)                
        end
      end
      
      backup_service = EnginesOSapi.loadManagedService("backup",@docker_api)
    if backup_service.is_a?(EnginesOSapiResult)
            return backup_service
          end
    backup_service.add_consumer(backup_hash)
#    p backup_hash
    return success(engine_name,"Add Volume Backup")
  end
  
  def stop_backup backup_name
    backup_service = EnginesOSapi.loadManagedService("backup",@docker_api)
  if backup_service.is_a?(EnginesOSapiResult)
          return backup_service
        end
    backup_hash = Hash.new
    backup_hash[:name]=backup_name
  backup_service.remove_consumer(backup_hash)
  return success(backup_name,"Stop Backup")
  end
  
  def backup_database(backup_name,engine_name,database_name,dest_hash)
    
     engine = loadManagedEngine engine_name
       if engine.is_a?(EnginesOSapiResult)
         return engine
       end
    
       backup_hash = dest_hash
       backup_hash.store(:name, backup_name)
       backup_hash.store(:engine_name, engine_name)
       backup_hash.store(:backup_type, "db")
       engine.databases.each do |database|
         if database.name == database_name
           database.add_backup_src_to_hash(backup_hash)                
         end
       end
       
       backup_service = EnginesOSapi.loadManagedService("backup",@docker_api)
     if backup_service.is_a?(EnginesOSapiResult)
             return backup_service
           end
     backup_service.add_consumer(backup_hash)
     return success(engine_name,"Add Database Backup")
   end

   def get_system_preferences 
     return docker_api.load_system_preferences
   end
   
   def save_system_preferences preferences
     #preferences is a hash
     return docker_api.save_system_preferences
   end
  
  def recreateEngine engine_name
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return engine
    end
    retval = engine.recreate_container()
    if retval == false
      return failed(engine_name,"No Engine","Stop")
    else
      return success(engine_name,"Stop")
    end
  end

  def stopEngine engine_name
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return engine
    end
    retval = engine.stop_container()
    if retval == false
      return failed(engine_name,"No Engine","Stop")
    else
      return success(engine_name,"Stop")
    end
  end

  def startEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Start")
    end

    retval =  engine.start_container()

    if retval == false
      return failed(engine_name,engine.last_error,"Start")
    end
 
    return success(engine_name,"Start")

  end

  def pauseEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Pause")
    end

    retval = engine.pause_container

    if retval == false
      return failed(engine_name,engine.last_error,"Pause")
    end
    return success(engine_name,"Pause")

  end

  def enable_https_for_engine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","enable_https")
    end
    retval =  engine.enable_https()
    if retval == false
      return failed(engine_name,engine.last_error,"enable_https")
    end
    return success(engine_name,"enable_https")
  end
  def enable_httpsonly_for_engine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","enable_httpsonly")
    end
    retval =  engine.enable_httpsonly()
    if retval == false
      return failed(engine_name,engine.last_error,"enable_httpsonly")
    end
    return success(engine_name,"enable_httpsonly")
  end
  
  def disable_httpsonly_for_engine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","disable_httpsonly")
    end
    retval =  engine.disable_httpsonly()
    if retval == false
      return failed(engine_name,engine.last_error,"disable_httpsonly")
    end
    return success(engine_name,"disable_httpsonly")
  end
  
  def disable_https_for_engine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","disable_https")
    end
    retval =  engine.disable_https()
    if retval == false
      return failed(engine_name,engine.last_error,"disable_https")
    end
    return success(engine_name,"disable_https")
   end
   
   
  def unpauseEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Unpause")
    end
    retval =  engine.unpause_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Unpause")
    end
    return success(engine_name,"unpause")

  end

  def destroyEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Destroy")
    end
    retval =   engine.destroy_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Destroy")
    end
    return success(engine_name,"Destroy")
  end

  def deleteEngineImage engine_name
    engine = loadManagedEngine engine_name
    if   engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Delete")
    end
    retval =   engine.delete_image()
    if retval == false
      return failed(engine_name,engine.last_error,"Delete")
    end
    return success(engine_name,"Delete")
  end

  def createEngine engine_name
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return  engine #acutally EnginesOSapiResult
    end
    retval =   engine.create_container()
    if retval == false
      p failed(engine_name,engine.last_error,"Create")

      return failed(engine_name,engine.last_error,"Create")
    end
    return success(engine_name,"Create")
  end

  def restartEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Restart")
    end
    retval =   engine.restart_container()
    if retval == false
      return failed(engine_name,engine.last_error,"Restart")
    end
    return success(engine_name,"Restart")
  end

  def registerEngineWebSite engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Register Engine Web Site")
    end
    retval =  engine.register_site()
    if retval != true
      return failed(engine_name,retval,"Register Engine Web Site")
    end
    return success(engine_name,"Register Engine Web Site")
  end

  def deregisterEngineWebSite engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","DeRegister Engine Web Site")
    end
    retval =   engine.deregister_site()
    if retval != true
      return failed(engine_name,retval,"DeRegister Engine Web Site")
    end
    return success(engine_name,"DeRegister Engine Web Site")
  end

  def registerEngineDNS engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Register Engine DNS")
    end

    retval = engine.register_dns()

    if retval.is_a?(String)
      p retval
      return failed(engine_name,retval,"Register Engine DNS")
    end
    return success(engine_name,"Register Engine DNS")
  end

  def deregisterEngineDNS engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","DeRegister Engine DNS")
    end
    retval = engine.deregister_dns()
    if  retval.is_a?(String)
      return failed(engine_name,retval,"DeRegister Engine DNS")
    end
    return success(engine_name,"DeRegister Engine DNS")
  end

  def monitorEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Monitor Engine")
    end
    retval = engine.monitor_site()
    if  retval.is_a?(String)
      return failed(engine_name,retval,"Monitor Engine")
    end
    return success(engine_name,"Monitor Engine")
  end

  def demonitorEngine engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","DeMonitor Engine")
    end
    retval = engine.demonitor_site()
    if  retval.is_a?(String)
      return failed(engine_name,retval,"DeMonitor Engine")
    end
    return success(engine_name,"DeMonitor Engine")
  end

  def get_engine_blueprint engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Load Engine Blueprint")
    end
    retval = engine.load_blueprint()
    if retval == false
      return failed(engine_name,engine.last_error,"Load Engine Blueprint")
    end
    return retval
  end

  def rebuild_engine_container engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Load Engine Blueprint")
    end
    state = engine.read_state
    if state == "running" || state == "paused"
      return failed(engine_name,"Cannot rebuild a container in State:" + state,"Rebuild Engine")
    end
    retval = engine.rebuild_container
    if retval.is_a?(ManagedEngine)
      success(engine_name,"Rebuild Engine Image")
    else
      puts "rebuild error"
      p engine.last_error
      return failed(engine_name,"Cannot rebuild Image:" + engine.last_error,"Rebuild Engine")

    end
  end

  #not needed as inherited ???
  def read_state container
    retval =   container.read_state()
    # if retval == false
    #  return failed(container.containerName,"Failed to ReadState","read state")
    #end
    #return success(container.containerName,"read state")
    retval
  end

  def stopService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Stop Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.stop_container()
    if retval == false
      return failed(service_name,service.last_error,"Stop Service")
    end
    return success(service_name,"Stop Service")
  end

  def startService service_name
    service = getManagedService(service_name)
    if service == nil  
      return failed(service_name,"No Such Service","Start Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval = service.start_container()
    if retval == false
      return failed(service_name,service.last_error,"Start Service")
    end
    return success(service_name,"Start Service")
  end

  def  pauseService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Pause Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval = service.pause_container()
    if retval == false
      return failed(service_name,service.last_error,"Pause Service")
    end
    return success(service_name,"Pause Service")
  end

  def  unpauseService service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Unpause Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval = service.unpause_container()
    if retval == false
      return failed(service_name,service.last_error,"Unpause Service")
    end
    return success(service_name,"Unpause Service")
  end

  def registerServiceWebSite service_name
    service = getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Register Service Web")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.register_site()
    if retval != true
      return failed(service_name,service.last_error,"Register Service Web")
    end
    return success(service_name,"Register Service Web")
  end

  def deregisterServiceWebSite service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,"No Such Service","Deregister Service Web")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.deregister_site()
    if retval != true
      return failed(service_name,service.last_error,"Deregister Service Web")
    end
    return success(service_name,"Deregister Service Web")
  end

  def registerServiceDNS service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Register Service DNS")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.register_dns()

    if retval != true
      return failed(service_name,retval,"Register Service DNS")
    end
    return success(service_name,"Register Service DNS")
  end

  def deregisterServiceDNS service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Deregister Service DNS")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.deregister_dns()
    if retval != true
      return failed(service_name,retval,"Deregister Service DNS")
    end
    return success(service_name,"Deregister Service DNS")
  end

  def createService service_name
    service =getManagedService(service_name)
    if service == nil
      return  failed(service_name,service.last_error,"Create Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.create_service()
    if retval == false
      return failed(service_name,service.last_error,"Create Service")
    end
    return success(service_name,"Create Service")
  end

  def recreateService service_name
    service =getManagedService(service_name)
    if service == nil
      return failed(service_name,"No Such Service","Recreate Service")
    end
    
    if service.is_a?(EnginesOSapiResult)
      return service
    end
    
    retval =   service.recreate()
    if retval == false
      return failed(service_name,service.last_error,"Recreate Service")
    end
    return success(service_name,"Recreate Service")
  end

  def get_volumes
     
    vol_service = EnginesOSapi.loadManagedService("volmanager",@dockerapi)
    if vol_service == nil
       return failed("volmanager","No Such Service","get_volumes")
     end
     
    return vol_service.consumers
      
    end
  def get_databases
    db_service = EnginesOSapi.loadManagedService("mysql_server",@dockerapi)
    if db_service == nil
      return failed("mysql_server","No Such Service","get_databases")
    end         
    return db_service.consumers          
  end
  def get_backups
    backup_service = EnginesOSapi.loadManagedService("backup",@dockerapi)
    if backup_service == nil
      return failed("backup service","No Such Service","get_backup list")
    end
    return backup_service.consumers
  end

  def set_engine_hostname_details(params)
    engine_name = params[:engine_name]
    hostname = param[:hostname]
    domain_name = param[:domain_name]
    #FIXME Do stuff here
  end
      
  #protected if protected static cant call
  def success(item_name ,cmd)
    EnginesOSapi.success(item_name ,cmd)
  end

  def failed(item_name,mesg ,cmd)
    EnginesOSapi.failed(item_name,mesg ,cmd)
  end

  def EnginesOSapi.success(item_name ,cmd)
    return  EnginesOSapiResult.new(true,0,item_name, "OK",cmd)
  end

  def EnginesOSapi.failed(item_name,mesg ,cmd)
    return  EnginesOSapiResult.new(false,-1,item_name, mesg,cmd)
  end

end
