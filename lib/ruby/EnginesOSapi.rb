require "/opt/engines/lib/ruby/ManagedContainer.rb"
require "/opt/engines/lib/ruby/SysConfig.rb"
require "/opt/engines/lib/ruby/EngineBuilder.rb"
require "/opt/engines/lib/ruby/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/EnginesOSapiResult.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require "/opt/engines/lib/ruby/prefs/SystemPreferences.rb"
require 'objspace'

class EnginesOSapi
  def initialize()
    @core_api = EnginesCore.new
  end

  def core_api
    return @core_api
  end
  
 ##fix me and put in system api
  def first_run_required?
    if File.exists?(SysConfig.FirstRunRan) ==false      
        return true
    end
    return false
  end

  def set_first_run_parameters params
    p params
    #required
   #:admin_password
    #:ssh_password
    #:mysql_password
    #:psql_password
    #default_domain
    
#optional and can be set latter
    
    
#ssl details
    #:ssl_country    
    #:ssl_state
    #:ssl_city
    #:ssl_organisation
    #:ssl_person_name

#smarthost        
      #smarthost_hostname    
      #smarthost_port
      #smarthost_username
      #smarthost_password
      #smarthost_authtype
    
    
    
    f= File.new(SysConfig.FirstRunRan,"w")
           date= DateTime.now
           f.puts(date.to_s)
           f.close    
           
    return success("Gui","First Run")
  end
  
  def buildEngine(repository,host,domain_name,environment)
    engine_builder = EngineBuilder.new(repository,host,host,domain_name,environment, @core_api)
    engine = engine_builder.build_from_blue_print
    if engine == false
      return  failed(host,last_api_error,"build_engine") 
    end
    if engine != nil
      engine.save_state
      return engine
    end
    return  failed(host,last_api_error,"build_engine") 

  rescue Exception=>e
    return log_exception_and_fail("buildEngine",e)
  end

  def build_engine(repository,params)
#    container_name = params[:engine_name]
#    domain_name = params[:domain_name]
#    host_name = params[:host_name]
#    evirons = params[:env_variables]
    params[:repository] = repository
    p params
    #@engine_builder = EngineBuilder.new(repository,container_name,host_name,domain_name,evirons, @core_api)
    @engine_builder = EngineBuilder.new(params, @core_api)
    engine = @engine_builder.build_from_blue_print
    if engine == false
      return  failed(params[:engine_name],engine_builder.last_error,"build_engine")
    end
    if engine != nil
      if engine.is_active == false
        return failed(params[:engine_name],"Failed to start  " + last_api_error ,"build_engine")
      end
      return engine
    end
    return failed(host_name,last_api_error,"build_engine")

  rescue Exception=>e
    return log_exception_and_fail("build_engine",e)
  end

  def get_engine_builder_streams
    if @engine_builder.present?
      return  ([@engine_builder.get_build_log_stream,  @engine_builder.get_build_err_stream])
    end 
    return nil
  end
  
  def last_api_error
    if @core_api
      return @core_api.last_error
    else
      return ""
    end
  rescue Exception=>e
    return log_exception_and_fail("last_api_error",e)
  end

  def list_apps()
    return @core_api.list_managed_engines
  rescue Exception=>e
    return log_exception_and_fail("list_apps",e)
  end

  def list_services()
    return @core_api.list_managed_services
  rescue Exception=>e
    return log_exception_and_fail("list_services",e)
  end

  def getManagedEngines()
    return  @core_api.getManagedEngines()
  rescue Exception=>e
    return log_exception_and_fail("getManagedEngines",e)
  end

  def getManagedServices()
    return @core_api.getManagedServices()
  rescue Exception=>e
    return log_exception_and_fail("getManagedServices",e)
  end

  def EnginesOSapi.loadManagedService(service_name,core_api)
    service = core_api.loadManagedService(service_name)
    if service == false
      return failed(service_name,last_api_error ,"Load Service")
    end
    return service
  rescue Exception=>e
    return log_exception_and_fail("LoadMangedService",e)
  end

  def loadManagedEngine(engine_name)
    engine = @core_api.loadManagedEngine(engine_name)   
    if engine == false
      return failed(engine_name,last_api_error ,"Load Engine")
    end
    return engine
  rescue Exception=>e
    return log_exception_and_fail("loadManagedEngine",e)
  end

  def getManagedService(service_name)

    managed_service = EnginesOSapi.loadManagedService(service_name,@core_api)
    #  if managed_service == nil
    #   return failed(service_name,"Fail to Load configuration:","Load Service")
    #end
    return managed_service
  rescue Exception=>e
    return log_exception_and_fail("getManagedService",e)
  end

  def backup_volume(params)
    
    backup_name = params[:backup_name]
    engine_name = params[:engine_name]
    volume_name  = params[:source_name]
    dest_hash  = params[:destination_hash]
      
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return engine
    end
    SystemUtils.debug_output("backing up " + volume_name + " to " +  dest_hash.to_s )
    backup_hash = dest_hash
    backup_hash.store(:name, backup_name)
    backup_hash.store(:engine_name, engine_name)
    backup_hash.store(:backup_type, "fs")
    
      if engine.volumes.present?     
        volume =  engine.volumes["volume_name"]
          if volume.present?
            volume.add_backup_src_to_hash(backup_hash)
            SystemUtils.debug_output backup_hash
          end
     end           
#    engine.volumes.values do |volume|
#      if volume.name == volume_name
#        volume.add_backup_src_to_hash(backup_hash)
#        SystemUtils.debug_output backup_hash
#      end
#    end

    backup_service = EnginesOSapi.loadManagedService("backup",@core_api)
    if backup_service.is_a?(EnginesOSapiResult)
      return backup_service
    end
    if backup_service.read_state != "running"
      return failed(engine_name,"Backup Service not running" ,"Backup Volume")
    end
    if backup_service.add_consumer(backup_hash)
      #    p backup_hash
      return success(engine_name,"Add Volume Backup")
    else
      return failed(engine_name,last_api_error,"Backup Volume")
    end
  rescue Exception=>e
    return log_exception_and_fail("Backup Volume",e)
  end

  def stop_backup backup_name
    backup_service = EnginesOSapi.loadManagedService("backup",@core_api)
    if backup_service.is_a?(EnginesOSapiResult)
      return backup_service
    end
    if backup_service.read_state != "running"
      return failed(engine_name,"Backup Service not running" ,"Stop Volume Backup")
    end
    backup_hash = Hash.new
    backup_hash[:name]=backup_name
    if  backup_service.remove_consumer(backup_hash)
      return success(backup_name,"Stop Volume Backup")
    else
      return failed(backup_name,last_api_error,"Stop Volume Backup")
    end
  rescue Exception=>e
    return log_exception_and_fail("Stop Volume Backup",e)
  end

  def backup_database(params)#backup_name,engine_name,database_name,dest_hash)

    backup_name = params[:backup_name]
    engine_name = params[:engine_name]
    database_name = params[:source_name]    
    dest_hash = params[:destination_hash]
      
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return engine
    end
    params 
    backup_hash = dest_hash
    backup_hash.store(:name, backup_name)
    backup_hash.store(:engine_name, engine_name)
    backup_hash.store(:backup_type, "db")
    engine.databases.each do |database|
      if database.name == database_name
        database.add_backup_src_to_hash(backup_hash)
      end
    end

    backup_service = EnginesOSapi.loadManagedService("backup",@core_api)
    if backup_service.is_a?(EnginesOSapiResult)
      return backup_service
    end
    if backup_service.read_state != "running"
      return failed(engine_name,"Backup Service not running" ,"Backup Database")
    end
    if backup_service.add_consumer(backup_hash)
      return success(engine_name,"Add Database Backup")
    else
      return  failed(backup_name,last_api_error,"Backup Database")
    end
  rescue Exception=>e
    return log_exception_and_fail("Backup Database",e)
  end

  def get_system_preferences
    return core_api.load_system_preferences
  rescue Exception=>e
    return log_exception_and_fail("get_system_preferences",e)
  end

  def save_system_preferences preferences
    #preferences is a hash
    # :default_domain need to set on mail server
    # :elsewhere ssl cert for mgmt?
    
    #default web_site
    #{..... email=>{smart_host=> X , smart_host_type=>y, smart_host_username=>z, smart_host_password=>xxx}} 
    
    return core_api.save_system_preferences
  rescue Exception=>e
    return log_exception_and_fail("save_system_preferences",e)
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
  rescue Exception=>e
    return log_exception_and_fail("recreateEngine",e)
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
  rescue Exception=>e
    return log_exception_and_fail("stopEngine",e)
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
  rescue Exception=>e
    return log_exception_and_fail("startEngine",e)
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
  rescue Exception=>e
    return log_exception_and_fail("startEngine",e)
  end

#  def enable_https_for_engine engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","enable_https")
#    end
#    retval =  engine.enable_https()
#    if retval == false
#      return failed(engine_name,engine.last_error,"enable_https")
#    end
#    return success(engine_name,"enable_https")
#  rescue Exception=>e
#    return log_exception_and_fail("enable_https",e)
#  end
#
#  def enable_httpsonly_for_engine engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","enable_httpsonly")
#    end
#    retval =  engine.enable_httpsonly()
#    if retval == false
#      return failed(engine_name,engine.last_error,"enable_httpsonly")
#    end
#    return success(engine_name,"enable_httpsonly")
#  rescue Exception=>e
#    return log_exception_and_fail("enable_httpsonly",e)
#  end
#
#  def disable_httpsonly_for_engine engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","disable_httpsonly")
#    end
#    retval =  engine.disable_httpsonly()
#    if retval == false
#      return failed(engine_name,engine.last_error,"disable_httpsonly")
#    end
#    return success(engine_name,"disable_httpsonly")
#  rescue Exception=>e
#    return log_exception_and_fail("disable_httpsonly",e)
#  end
#
#  def disable_https_for_engine engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","disable_https")
#    end
#    retval =  engine.disable_https()
#    if retval == false
#      return failed(engine_name,engine.last_error,"disable_https")
#    end
#    return success(engine_name,"disable_https")
#  rescue Exception=>e
#    return log_exception_and_fail("disable_https",e)
#  end

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
  rescue Exception=>e
    return log_exception_and_fail("unpause",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Destroy",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Delete",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Create",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Restart",e)
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
  rescue Exception=>e
    return log_exception_and_fail("DeRegister Engine Web Site",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Register Engine DNS",e)
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
  rescue Exception=>e
    return log_exception_and_fail("deRegister Engine DNS",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Monitor Engine",e)
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
  rescue Exception=>e
    return log_exception_and_fail("DeMonitor Engine",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Load Engine Blueprint",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Rebuild Engine",e)
  end

  #not needed as inherited ???
  def read_state container

    retval =   container.read_state()
    # if retval == false
    #  return failed(container.containerName,"Failed to ReadState","read state")
    #end
    #return success(container.containerName,"read state")
    retval
  rescue Exception=>e
    return log_exception_and_fail("read_start",e)
  end

  def log_exception_and_fail(cmd,e)
    e_str = log_exception(e)
    return failed("Exception",e_str,cmd)
  end

  def log_exception(e)
    @last_error =  e_str = e.to_s()
    e.backtrace.each do |bt |
      e_str += bt
    end
    SystemUtils.log_output(e_str,10)
    return e_str
  end

  def get_system_memory_info
    return @core_api.get_system_memory_info
  rescue Exception=>e
    return log_exception_and_fail("get_system_memory_info",e)
  end

  def get_system_load_info
    return @core_api.get_system_load_info
  rescue Exception=>e
    return log_exception_and_fail("get_system_load_info",e)
  end

  def get_engine_memory_statistics  engine_name
    engine = loadManagedEngine engine_name
    if  engine.is_a?(EnginesOSapiResult)
      return failed(engine_name,"no Engine","Get Engine Memory Statistics")
    end
    retval = engine.get_container_memory_stats(@core_api)
    return retval
  rescue Exception=>e
    return log_exception_and_fail("Get Engine Memory Statistics",e)
  end

  def get_service_memory_statistics  service_name
    service = getManagedService(service_name)
    if  service.is_a?(EnginesOSapiResult)
      return failed(service_name,"no Engine","Get Service Memory Statistics")
    end
    retval = service.get_container_memory_stats(@core_api)
    return retval
  rescue Exception=>e
    return log_exception_and_fail("Get Service Memory Statistics",e)
  end

  def get_container_network_metrics(containerName)
    return @core_api.get_container_network_metrics(containerName)
  rescue Exception=>e
    return log_exception_and_fail("get_container_network_metrics",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Stop Service",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Start Service",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Pause Service",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Unpause Service",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Register Service Web",e)
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
  rescue Exception=>e
    return log_exception_and_fail("DeRegister Service Web",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Register Service DNS",e)
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
  rescue Exception=>e
    return log_exception_and_fail("DeRegister Service DNS",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Create Service",e)
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
  rescue Exception=>e
    return log_exception_and_fail("Recreate Service",e)
  end

  def get_volumes

    vol_service = EnginesOSapi.loadManagedService("volmanager",@core_api)
    if vol_service == nil
      return failed("volmanager","No Such Service","get_volumes")
    end

    return vol_service.consumers
  rescue Exception=>e
    return log_exception_and_fail("get_volumes",e)
  end

  def get_databases
    db_service = EnginesOSapi.loadManagedService("mysql_server",@core_api)
    if db_service == nil
      return failed("mysql_server","No Such Service","get_databases")
    end
    return db_service.consumers
  end

  def get_backups
    backup_service = EnginesOSapi.loadManagedService("backup",@core_api)
    if backup_service == nil
      return failed("backup service","No Such Service","get_backup list")
    end
    return backup_service.consumers
  rescue Exception=>e
    return log_exception_and_fail("get_backup list",e)
  end
  
  def set_engine_runtime_properties params
    return success(params[:engine_name],"update engine runtime params")
    rescue Exception=>e
        return log_exception_and_fail("set_engine_runtime params ",e)
  end
  def set_service_runtime_properties params
     return success(params[:engine_name],"update service runtime params")
     rescue Exception=>e
         return log_exception_and_fail("update service runtime params ",e)
   end
  def set_service_hostname_properties(params)
    return success(params[:engine_name],"update service hostname params")
       rescue Exception=>e
           return log_exception_and_fail("set_engine_hostname_details ",e)
  end
  def set_engine_network_properties(params)
    p :set_engine_network_properties
       p params
    engine = loadManagedEngine(params[:engine_name])
       if engine == nil || engine.instance_of?(EnginesOSapiResult)
         p "p cant change network as cant load"
         p engine
         return engine
       end
    if @core_api.set_engine_network_properties(engine, params)
      return success(params[:engine_name], "Update network details")
       else
         return failed("set_engine_network_details",last_api_error,"set_engine_network_details")
       end
 end
 
 def get_available_services_for(item)
    res = @core_api.get_available_services_for(item)
     if res.present?
       return res
          else
            return failed("get avaiable services ",last_api_error,"get avaiable services")
          end
 end

  
  def set_engine_hostname_properties(params)
    #    engine_name = params[:engine_name]
    #    hostname = params[:host_name]
    #    domain_name = params[:domain_name]
    p :set_engine_hostname_properties
    p params
    engine = loadManagedEngine(params[:engine_name])
    if engine == nil || engine.instance_of?(EnginesOSapiResult)
      p "p cant change name as cant load"
      p engine
      return engine
    end
    if @core_api.set_engine_hostname_details(engine, params)
      return success(params[:engine_name], "Update hostname details")
    else
      return failed("set_engine_hostname_details",last_api_error,"set_engine_hostname_details")
    end
  rescue Exception=>e
    return log_exception_and_fail("set_engine_hostname_details ",e)
  end

  
  def update_domain(old_domain_name,params)
    if @core_api.update_domain(old_domain_name,params) == false
       return  failed(params[:domain_name],last_api_error, "update  domain")
    end  
  if params[:self_hosted] == false
    return success(params[:domain_name], "Add self hosted domain")
  end
    if @core_api.update_self_hosted_domain(old_domain_name, params) ==true
      return success(params[:domain_name], "Update self hosted domain")
    end
    return failed(params[:domain_name],last_api_error, "Update self hosted domain")
  rescue Exception=>e
    return log_exception_and_fail("Update self hosted domain ",e)
  end

  def add_domain params
    if @core_api.add_domain(params) == false
       return  failed(params[:domain_name],last_api_error, "Add  domain")
    end  
  if params[:self_hosted] == false
    return success(params[:domain_name], "Add domain")
  end
    if @core_api.add_self_hosted_domain( params) ==true
      return success(params[:domain_name], "Add self hosted domain")
    end
    return failed(params[:domain_name],last_api_error, "Add self hosted domain")
  rescue Exception=>e
    return log_exception_and_fail("Add self hosted domain ",e)
  end

  def create_ssl_certificate(params)
    p params
    return success(params[:domain_name], "Add self hosted ssl cert domain")        
  end
  def upload_ssl_certificate(params)
      p params
      return success(params[:domain_name], "upload self hosted ssl cert domain")        
    end
  def remove_domain domain_name
    if @core_api.remove_domain(params) == false
       return  failed(params[:domain_name],last_api_error, "Remove domain")
    end  
  if params[:self_hosted] == false
    return success(params[:domain_name], "Remove domain")
  end
    if @core_api.remove_self_hosted_domain( domain_name) ==true
      return success(domain_name, "Remove self hosted domain")
    end
    return failed(domain_name,last_api_error, "Remove self hosted domain")
  rescue Exception=>e
    return log_exception_and_fail("Remove self hosted domain ",e)
  end

  def list_domains
    return @core_api.list_self_hosted_domains( )
  rescue Exception=>e
    return log_exception_and_fail("list self hosted domain ",e)
  end

  def attach_ftp_service(params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Attach ftp")
  rescue Exception=>e
    return log_exception_and_fail("Attach ftp ",e)
  end

  def detach_ftp_service (params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Detach ftp")
  rescue Exception=>e
    return log_exception_and_fail("Detach ftp ",e)
  end

  def  change_ftp_service  (params)
    return  EnginesOSapiResult.new(true,0,params[:volume_name], "Success","Change ftp")
  rescue Exception=>e
    return log_exception_and_fail("Change ftp",e)
  end

  #protected if protected static cant call
  def success(item_name ,cmd)
    return EnginesOSapiResult.success(item_name ,cmd)
  end

  def failed(item_name,mesg ,cmd)
    p :engines_os_api_fail_on
    p item_name
    p mesg
    p cmd

    #    result = EnginesOSapiResult.failed(item_name,mesg ,cmd)
    #    return EnginesOSapi.APIException.new(result)
    return EnginesOSapiResult.failed(item_name,mesg ,cmd)
  end

  def  EnginesOSapi.failed(item_name,mesg ,cmd)
    p :engines_os_api_fail_on_static
    p item_name
    p mesg
    p cmd

    return EnginesOSapiResult.failed(item_name,mesg ,cmd)
  end

end
