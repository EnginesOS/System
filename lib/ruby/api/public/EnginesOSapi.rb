require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require "/opt/engines/lib/ruby/system/SysConfig.rb"
require "/opt/engines/lib/ruby/engine_builder/EngineBuilder.rb"
require "/opt/engines/lib/ruby/containers/ManagedContainerObjects.rb"

require "/opt/engines/lib/ruby/api/system/EnginesCore.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"

require 'objspace'

require_relative "EnginesOSapiResult.rb"
#
#require_relative "services_api.rb"
#include ServicesApi
#
#require_relative "engines_api.rb"
#include EnginesApi
#
#require_relative "build_api.rb"
#include BuildApi

class EnginesOSapi
  require_relative "build_controller.rb"
  include BuildController
  require_relative "engines_controller.rb"
  include EnginesController
  require_relative "services_module.rb"
  include ServicesModule
  
  def initialize()
    @core_api = EnginesCore.new
  end

  def core_api
    return @core_api
  end
  
  
  def log_exception_and_fail(cmd,e)
      e_str = SystemUtils.log_exception(e)
      return failed("Exception",e_str,cmd)
    end

 ##fix me and put in system api
  def first_run_required?      
    if File.exists?(SysConfig.FirstRunRan) ==false      
        return true
    end
    return false
  end

  def get_available_smtp_auth_types
    retval = ["plain","md5","?"]
      return retval
  end
  
  def set_smarthost(params)
    #smarthost_hostname"=>"203.14.203.141", "smarthost_username"=>"", "smarthost_password"=>"", "smarthost_authtype"=>"", "smarthost_port"=>"",
    return @core_api.set_smarthost(params) 
  end
  
  #@return EngineOSapiResult
  #set the default Domain used by the system in creating new engines and for services that use web
  def  set_default_domain(params)    
    if @core_api.set_default_domain(params)
      return success("Preferences","Set Default Domain")
    else
      return failed("Preferences", @core_api.last_error,"Set Default Domain")
    end
  end
  
  #@return String
  #get the default Domain used by the system in creating new engines and for services that use web
  def  get_default_domain()    
    return @core_api.get_default_domain() 
  end
  
  #@return boolean
   #set the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login 
  def set_default_site(params)
   if @core_api.set_default_site(params) 
    return success("Preferences","Set Default Site")
  else
    return failed("Preferences", @core_api.last_error,"Set Default Site")
  end
end
  #@return String
   #get the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login 
  def get_default_site()
    return @core_api.get_default_site 
  end
    
  def set_first_run_parameters params
    p params
  #  {"admin_password"=>"EngOS2014", "admin_password_confirmation"=>"EngOS2014", "ssh_password"=>"qCCedhQCb2", "ssh_password_confirmation"=>"qCCedhQCb2", "mysql_password"=>"TpBGZmQixr", "mysql_password_confirmation"=>"TpBGZmQixr", "psql_password"=>"8KqfESacSg", "psql_password_confirmation"=>"8KqfESacSg", "smarthost_hostname"=>"203.14.203.141", "smarthost_username"=>"", "smarthost_password"=>"", "smarthost_authtype"=>"", "smarthost_port"=>"", "default_domain"=>"engines.demo", "ssl_person_name"=>"test", "ssl_organisation_name"=>"test", "ssl_city"=>"test", "ssl_state"=>"test", "ssl_country"=>"AU"}
    
    params[:mail_name] = "smtp." + params[:default_domain]
    @core_api.setup_email_params(params)
         
        
    @core_api.set_database_password("mysql_server",params)              
    @core_api.set_database_password("pgsql_server",params)    
        
    @core_api.set_engines_ssl_pw(params)
    
    params[:default_cert]=true      
  #  create_ssl_certificate(params)
     
    f = File.new(SysConfig.FirstRunRan,"w")
           date = DateTime.now
           f.puts(date.to_s)
           f.close    
           
    return success("Gui","First Run")
    rescue Exception=>e
    SystemUtils.log_exception(e)
    
      return failed("Gui","First Run","failed")
    
  end
  
  

#    def reinstall_engine engine_name
#      
#      engine = loadManaged(engine_name)
#      
#      if engine.is_a?(EnginesOSapiResult)
#        return engine
#      end
#      if engine.is_active == true
#        return  failed(host,"Cannot reinstall running engine:" + engine_name,"reinstall_engine") 
#      end
#      if engine.has_container? == true
#       if engine.destroy == false
#         return  failed(host,"Failed to destroy engine:" + engine_name,"reinstall_engine") 
#       end
#      end
#      params = Hash.new
#      
#      params[:engine_name] = engine.container_name  
#      params[:domain_name] = engine.domain_name
#      params[:host_name] = engine.hostname
#      params[:software_environment_variables] = engine.environments 
#      params[:http_protocol] = engine.http_protocol
#      params[:memory] = engine.memory
#      params[:repository_url] = engine.repo
#        
#      build_engine(params)
#      #   custom_env=params
#     
#    end
  
  
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
    p :list_apps
    return @core_api.list_managed_engines
  rescue Exception=>e
    return log_exception_and_fail("list_apps",e)
  end



  def getManagedEngines()
    return  @core_api.getManagedEngines()
  rescue Exception=>e
    return log_exception_and_fail("getManagedEngines",e)
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

 

  def backup_volume(params)
    
    backup_name = params[:backup_name]
    engine_name = params[:engine_name]
    volume_name  = params[:source_name]
    dest_hash  = params[:destination_hash]
      
    engine = loadManagedEngine engine_name
    if engine.is_a?(EnginesOSapiResult)
      return engine
    end
    SystemUtils.debug_output("backing up " + volume_name + " to " ,  dest_hash )
    backup_hash = dest_hash
    backup_hash.store(:name, backup_name)
    backup_hash.store(:engine_name, engine_name)
    backup_hash.store(:backup_type, "fs")
    backup_hash.store(:parent_engine,engine_name)
    
      if engine.volumes != nil     
        volume =  engine.volumes["volume_name"]
          if volume != nil
            volume.add_backup_src_to_hash(backup_hash)
            SystemUtils.debug_output("Backup hash",backup_hash)
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
    
    return core_api.save_system_preferences(preferences)
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

  def deleteEngineImage(engine_name,params) 
    
    #
    engine = loadManagedEngine engine_name
    if   engine.is_a?(EnginesOSapiResult)
      SystemUtils.log_error_mesg("no Engine to delete",params)
      return failed(engine_name,"no Engine","Delete")
    end
  
    params[:engine_name] = engine_name
      p :deleteEngineImage_params
      p params
   if  @core_api.delete_image_dependancies(params) == true
     if engine.delete_image() == true
       return success(engine_name,"Delete")
     end
   else
     SystemUtils.log_error_mesg("failed to delete image dependancies ",params)
      return failed(params[:engine_name],last_api_error, "Delete Image Dependancies")     
   end
   
   SystemUtils.log_error_mesg("failed to delete image ",params)
   return  failed(params[:engine_name],last_api_error, "Delete Image")

  rescue Exception=>e
    return log_exception_and_fail("Delete",e)
 
  end

 
  
  def reinstall_engine(engine_name)
    engine = loadManagedEngine engine_name
      if engine.is_a?(EnginesOSapiResult)
        return  engine #acutally EnginesOSapiResult
      end
      if engine.has_container? == true
        engine.destroy_container
      end
      p "reinstalling " + engine_name
    if @core_api.reinstall_engine(engine) == false
                return  failed(engine_name,last_api_error, "Delete Image")
             end  
    return success(engine_name,"Reinstall")
     
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



  def get_engine_blueprint engine_name
#    p :get_blueprint_for
#    p engine_name
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

  #not needed as inherited ???
  def read_state container

    retval =   container.read_state()
    # if retval == false
    #  return failed(container.container_name,"Failed to ReadState","read state")
    #end
    #return success(container.container_name,"read state")
    retval
  rescue Exception=>e
    return log_exception_and_fail("read_start",e)
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

  def get_container_network_metrics(container_name)
    return @core_api.get_container_network_metrics(container_name)
  rescue Exception=>e
    return log_exception_and_fail("get_container_network_metrics",e)
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
  
  def set_engine_runtime_properties(params)
    if @core_api.set_engine_runtime_properties(params) ==true
        return success(params[:engine_name],"update engine runtime params")
    end
      
   return  failed(params[:engine_name], @core_api.last_error,"update engine runtime params")
    rescue Exception=>e
        return log_exception_and_fail("set_engine_runtime params ",e)
  end
  def set_service_runtime_properties params
     return success(params[:engine_name],"update service runtime params")
     rescue Exception=>e
         return log_exception_and_fail("update service runtime params ",e)
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
 

  
 def default_backup_service_definition(params)
   #FixMe read backup from mappings
   
   return SoftwareServiceDefinition.find("backup","EnginesSystem")   
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

  
  def update_domain(params)
    old_domain_name=params[:original_domain_name]
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
    #params[:default_cert]
    #""default_domain"=>"engines.demo", "ssl_person_name"=>"test", "ssl_organisation_name"=>"test", "ssl_city"=>"test", "ssl_state"=>"test", "ssl_country"=>"AU"}
    return success(params[:domain_name], "Add self hosted ssl cert domain")        
  end
  def upload_ssl_certificate(params)
      p params
      return success(params[:domain_name], "upload self hosted ssl cert domain")        
    end
    
  def remove_domain params    
    if @core_api.remove_domain(params) == false
      p :remove_domain_last_error
      p last_api_error
       return  failed(params[:domain_name],last_api_error, "Remove domain")
    end  
  if params[:self_hosted] == false
    return success(params[:domain_name], "Remove domain")
  end
  
    if @core_api.remove_self_hosted_domain( params[:domain_name]) ==true
      return success(params[:domain_name], "Remove self hosted domain")
    end
    return failed(params[:domain_name],last_api_error, "Remove self hosted domain")
  rescue Exception=>e
    return log_exception_and_fail("Remove self hosted domain " + params[:domain_name],e)
  end

  def list_self_hosted_domains
    return @core_api.list_self_hosted_domains( )
  rescue Exception=>e
    return log_exception_and_fail("list self hosted domain ",e)
  end

  def list_domains
    return @core_api.list_domains( )
  rescue Exception=>e
    return log_exception_and_fail("list domains ",e)
  end 
  
  def list_service_providers_in_use
     return @core_api.list_providers_in_use
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

  def  self.failed(item_name,mesg ,cmd)
    p :engines_os_api_fail_on_static
    p item_name
    p mesg
    p cmd

    return EnginesOSapiResult.failed(item_name,mesg ,cmd)
  end
  

  #@returns EnginesOSapiResult on sucess with private ssh key in repsonse messages
  def generate_engines_user_ssh_key
    res = @core_api.generate_engines_user_ssh_key
    if res == true    
      return success("Engines ssh key regen", res)
    end
    
    return failed("Update System SSH key",@core_api.last_error ,"Update System SSH key")
          
  end
  
  #calls api to run system update
  #@return EnginesOSapiResult
  def system_update
    res = @core_api.system_update
    if res == false
      return failed("System Update",@core_api.last_error ,"Update")
    end
    return success("System Update", res)        
  end
  
end
