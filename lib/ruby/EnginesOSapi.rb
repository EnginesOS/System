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
    @docker_api = Engines.new
  end

  def docker_api
    return @docker_api
  end

  
  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,host,domain_name,environment, @docker_api)
    engine = engine_builder.build_from_blue_print
    if engine == false
      return  failed(host,@docker_api.last_error,"build_engine") #FIXME needs to return error object
    end
    if engine != nil
      engine.save_state
      return engine
    end
    return  failed(host,"Failed","build_engine") #FIXME needs to return error object

  end
  def build_engine(repository,params)    
    container_name = params[:container_name]
    domain_name = params[:domain_name]
    host_name = params[:host_name]
   evirons = params[:env_variables]
    container_name = host_name
     p params
#     if container_name == nil || host_name == nil|| domain_name == nil
#       container_name = "test"
#       host_name ="test"
#       domain_name ="localdemo.jvodan.home"
#       #FIXME needs to return error object
#      # return  failed(host_name,"Incorrect Parameters","build_engine") 
#     end
      engine_builder = EngineBuilder.new(repository,container_name,host_name,domain_name,evirons, @docker_api)
      engine = engine_builder.build_from_blue_print
    if engine == false
      return  failed(host_name,engine_builder.last_error,"build_engine") 
    end
      if engine != nil
        engine.save_state
        return engine
      end
      return failed(host_name,"Failed","build_engine") 
  
  end
  def last_api_error
    if @docker_api
      return @docker_api.last_error
    else
      return ""
    end
  end
    
  def list_apps()
    return @docker_api.list_managed_engines
  end
  
  def list_services()   
     return @docker_api.list_managed_services
   end
   
   def getManagedEngines()
     return  @docker_api.getManagedEngines()
   end
   
  
  def getManagedServices()
    return @docker_api.getManagedEngines()        
  end
 

  def EnginesOSapi.loadManagedService(service_name,docker_api)
    service = docker_api.loadManagedService(service_name)
    if service == false
       return failed(service_name,"Could not load service" ,"Load Service")
     end
    return service
  end
  
  def loadManagedEngine(engine_name)
    engine = @docker_api.loadManagedEngine(engine_name)
    if engine == false
       return failed(engine_name,"Could not load engine" ,"Load Engine")
     end
    return engine
  end
  

  def getManagedService(service_name)

    managed_service = EnginesOSapi.loadManagedService(service_name,@docker_api)
    #  if managed_service == nil
    #   return failed(service_name,"Fail to Load configuration:","Load Service")
    #end
    return managed_service
  end

  
  
  def backup_volume(backup_name,engine_name,volume_name,dest_hash)
    engine = loadManagedEngine engine_name
      if engine.is_a?(EnginesOSapiResult)
        return engine
      end
    SystemUtils.debug_output("backing up " + volume_name + " to " +  dest_hash )
      backup_hash = dest_hash
      backup_hash.store(:name, backup_name)
    backup_hash.store(:engine_name, engine_name)
    backup_hash.store(:backup_type, "fs")
      engine.volumes.each do |volume|
        if volume.name == volume_name
          volume.add_backup_src_to_hash(backup_hash)   
          SystemUtils.debug_output backup_hash          
        end    
      end

      backup_service = EnginesOSapi.loadManagedService("backup",@docker_api)
    if backup_service.is_a?(EnginesOSapiResult)
            return backup_service
          end
      if backup_service.read_state != "running"
        return failed(engine_name,"Backup Service not running" ,"Backup Volume")
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
    if backup_service.read_state != "running"
      return failed(engine_name,"Backup Service not running" ,"Backup Volume")
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
    if backup_service.read_state != "running"
      return failed(engine_name,"Backup Service not running" ,"Backup Volume")
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

  def get_system_memory_info
    return @docker_api.get_system_memory_info
  end
  
  def get_system_load_info
    return @docker_api.get_system_load_info
  end
  def get_engine_memory_statistics  engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Get Engine Memory Statistics")
    end
    retval = engine.get_container_memory_stats(@docker_api)
    return retval    
  end
  
  def get_service_memory_statistics  service_name
    service = getManagedService(service_name)
     if  service.is_a?(EnginesOSapiResult)
       return failed(service_name,"no Engine","Get Service Memory Statistics")
     end
     retval = service.get_container_memory_stats(@docker_api)
     return retval    
   end
  
 def get_container_network_metrics(containerName)
   return @docker_api.get_container_network_metrics(containerName)
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
     
    vol_service = EnginesOSapi.loadManagedService("volmanager",@docker_api)
    if vol_service == nil
       return failed("volmanager","No Such Service","get_volumes")
     end
     
    return vol_service.consumers
      
    end
  def get_databases
    db_service = EnginesOSapi.loadManagedService("mysql_server",@docker_api)
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
#    engine_name = params[:engine_name]
#    hostname = params[:host_name]
#    domain_name = params[:domain_name]
    p :set_engine_hostname_details
    p params
    engine = loadManagedEngine(params[:engine_name])
      if engine == nil || engine.instance_of?(EnginesOSapiResult)
        p "p cant change name as cant load"
        p engine
        return engine        
      end
      return @docker_api.set_engine_hostname_details(engine, params)
  end
  
  def add_self_hosted_domain params
    return @docker_api.add_self_hosted_domain( params)
    #  EnginesOSapiResult.new(true,0,params[:domain_name], "OK","Add self hosted domain")
  end
  
  def remove_self_hosted_domain params
    return  EnginesOSapiResult.new(true,0,params[:domain_name], "Success","Remove self hosted domain")
  end
  
  def list_self_hosted_domains params
  domains = Hash.new
  return Hash
  end
  
  def attach_ftp_service(params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Attach ftp")
  end
  
  def detach_ftp_service (params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Detach ftp")
  end
      
  def  change_ftp_service  (params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Change ftp")
  end
  #protected if protected static cant call
  def success(item_name ,cmd)
    EnginesOSapiResult.success(item_name ,cmd)
  end

  def failed(item_name,mesg ,cmd)
    p item_name
    p mesg
    p cmd
    
    EnginesOSapiResult.failed(item_name,mesg ,cmd)
  end

 

end
