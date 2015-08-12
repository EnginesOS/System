require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require "/opt/engines/lib/ruby/system/SysConfig.rb"
require "/opt/engines/lib/ruby/engine_builder/EngineBuilder.rb"
require "/opt/engines/lib/ruby/containers/ManagedContainerObjects.rb"
require "/opt/engines/lib/ruby/api/system/EnginesCore.rb"
require "/opt/engines/lib/ruby/ManagedServices.rb"
require 'objspace'

require_relative "EnginesOSapiResult.rb"
require_relative "FirstRunWizard.rb"

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
  require_relative "BuildController.rb"
  
  require_relative "services_module.rb"
  include ServicesModule

  require_relative "engines_api_version.rb"
  include EngOSapiVersion
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

  def first_run_required?
    return FirstRunWizard.required?
  end

  
  
  ##Build stuff
  def build_engine(params)
    build_controller = BuildController.new(@core_api)
    p :building_with
    p params
    engine = build_controller.build_engine(params)
    p :Built
    if engine == false
      failed("Build Engine:",build_controller.last_error)
    end
    if engine.is_active? == false
      return failed(params[:engine_name],"Failed to start  " + build_controller.last_error.to_s ,"build_engine")
    end
    return success(params[:engine_name],"Build Engine")
  end
  
  def buildEngine(repository,host,domain_name,environment)
    build_controller = BuildController.new(@core_api)
       engine = build_controller.buildEngine(repository,host,domain_name,environment)
       if engine == false
         failed("Build Engine:",build_controller.last_error)
       end
       if engine.is_active? == false
         return failed(params[:engine_name],"Failed to start  " + build_controller.last_error.to_s ,"build_engine")
       end
       return success(params[:engine_name],"Build Engine")
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
  
    def build_engine_from_docker_image(params)
    p params
      return success(engine_name,"Build Engine from Docker Image")
  
    rescue Exception=>e
      return log_exception_and_fail("Build Engine from dockerimage",e)
    end
    
    
  def get_engine_build_report(engine_name)
    return   @core_api.get_build_report(engine_name)
  end
  
  def generate_private_key
    key = String.new()
    key = "-----BEGIN RSA PRIVATE KEY-----77La9gRav1qSbDAi9NNIbTH3GQ3vg7uLKGSOTFoyJ/TwQvwccJTFAoGBAMkKu/immL9ZMsheOQq1XlSglnbMk9wS4KphsQKBCou5lZdE9pWPHvYWuhRK9LW8g4HSS7RIQkm5B5H5b5A9RyJZ40bHy59S0R/lI4VTFi6lmpTr9d3ScVCAi/YdPkdeFS8RM5Q7F1OPg9I84zP1XmBPOvG5M86tAnCLa0PS7fCvAoGAOnJUeEkPoym4itA6fIq0OuM8+qtZ5wNVUvDD3QmfOIIsNiuNA69UtAYocwuQKwZDUb7PkOvWoIGtwA90QJDnr2UFDCAxaOuqzkL6p7xt2tn9llGYzeuyrO2rWeCIZ4UMokLonqnnLwP+0lV7eJys2HQ9MIIEoQIBAAKCAQEAsn9KZsQrePI+gxAxAizmDzXdsP0xw//f9rbfxZQNjI7kJsDx61UPJg/uDQ0VvQclll06UgN4+3YhbCInbDgv4T9SSOg7YD6fKnQiEuhLJxOCfoVo+NUebeEJz+NpCdcTyUdJGwjnbTNe6Jo/CgG0eyraDo4yPWzD4Zvt8R1G1WpQ5mOP9U2gd+9ThMm5ng1U9iWEtV/hq7Cn0UEJzOvKmKSvGEGBrRgSkwXmB1U4Yvs5BJoLtF6xyMn3uc+pZA4xZYH5scyplEatIEJlQZCnFeAbvfCl3QRUOipOmwDgv4A5VygK+IKdgmraKA+wyPZjp2bt4Gu+fPH4YRnTUM9iqwIBIwKCAQBbzG9oDR2r6kwI48Fu1UMdw+5bBd8UV7UCie9s7Q5ISXymN1fYHR27za2gT99LRYELgGci3TbnuRiAwRuWvc97J+EszzR6o9zUATYYWjVHS9y2GLmkitxzBgUL1AoiUVqiB2ds/UPRwqXWtboFJXLDABhfQdCx4Co5g2RtX4ODsii/gV0+lYU4tV3SdlmOJL2YuatqKiY5S0or9YuBfoq+0+kOP7Pj8/cPCUtCcGIr1C/A0kzyNXgpUZ5EBxbGPzs778Aas6h2N00GKTJSPrQfW8g90wWNIMVQ7BqrfygSDycpIYNlYX7bVJnrPTG3IF9wwATSTUWhmdaEnbmCkdDbAoGBAONK1rdVA+xM6hvUcatwvOUB7SQoloJiS9DEwM1eTr9Pj31UB/Hiuy3fDxS7MKdRPq+tJzOVJjdNo7IDNd6lTBveMBK2FXuUe8zLleGj5BozS/M9Uj0/RRJGljM4NHNMGmmq0x1BhVcCgYEAvY3HLEVOMMHQy4wJ5YZu4hPBEOzF7MFXfBL3WiHlXytSh0+mqkUdMSte/TC61zy2gbemdsfJeLXFTx5h38S/aYfzi+DzL9G93D5x8rwNmbIVZ9cppULCnFvxrYlJWTtzDx7Y3De26GK+Hf7k2TfOAwjfzffDIfOUlf/LiRdVX0UCgYAlc3Fbf3jh26jl/VDlvgPgzpv4I21pFCNKDDMjDAKdc46vEylIOTX98BMFRK2XPadZ6Z3dmo7u9rVA68NK03PJhfQLG63y/H8EJMeBrMYAaCQpNzdn//+DHClZhoF5ZGhuClzUjaVbreaxdsJ63Q2fNI23a5EOAeZucGplR5Vk8Q==\-----END RSA PRIVATE KEY-----"
    return @core_api.generate_engines_user_ssh_key
  end

  def update_public_key(key)
    if @core_ap.update_public_key(key) == false
      return success("Access","update public key")
    else
      return failed("Failed update key ",@core_api.last_error)
    end
  end

  def get_system_ca
    ca_string= File.read(SysConfig.EnginesInternalCA)
   return ca_string
  rescue Exception=>e
    return  failed("Failed to load CA",e.to_s)

  end

  def upload_ssl_certifcate (params)
    if param.has_key?(:certificate) == false ||  params.has_key?(:domain_name) == false
      p "errorexpect keys  :certificate :domain_name with optional :use_as_default"
      return  failed("error expect keys  :certificate :domain_name with optional :use_as_default", params)
    end
    return success("Access","upload Cert" + params[:domain_name])

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

  #
  #  #@return boolean
  #   #set the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
  def set_default_site(params)
    if @core_api.set_default_site(params)
      return success("Preferences","Set Default Site")
    else
      return failed("Preferences", @core_api.last_error,"Set Default Site")
    end
  end

  #  #@return String
  #   #get the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
  def get_default_site()
    return @core_api.get_default_site
  end

  def set_first_run_parameters params_from_gui

    params =params_from_gui.dup
    p params
    first_run = FirstRunWizard.new(params)
    first_run.apply(@core_api)
    if first_run.sucess == true
      return success("Gui","First Run")
    else
      p :first_run_error
      p first_run.error.to_s
      return failed("Gui","First Run",first_run.error.to_s)
    end

  rescue Exception=>e
    SystemUtils.log_exception(e)

    return failed("Gui","First Run","failed")

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

  def get_system_preferences
    return @core_api.load_system_preferences
  rescue Exception=>e
    return log_exception_and_fail("get_system_preferences",e)
  end

  def save_system_preferences preferences
    #preferences is a hash
    # :default_domain need to set on mail server
    # :elsewhere ssl cert for mgmt?

    #default web_site
    #{..... email=>{smart_host=> X , smart_host_type=>y, smart_host_username=>z, smart_host_password=>xxx}}

    return @core_api.save_system_preferences(preferences)
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

  def deleteEngineImage(params)
    if params.has_key?(:engine_name) == false || params[:engine_name] == nil
      return failed(params.to_s,"no Engine name","Delete")
    end
    engine = loadManagedEngine(params[:engine_name])
    if   engine.is_a?(EnginesOSapiResult)
      SystemUtils.log_error_mesg("no Engine to delete",params)
      return failed(params[:engine_name],"no Engine","Delete")
    end
    params[:container_type] = "container"
    if  @core_api.delete_image_dependancies(params) == true
      if engine.delete_image() == true
        return success(params[:engine_name],"Delete")
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
    #      p "reinstalling " + engine_name
    if @core_api.reinstall_engine(engine) == false
      return  failed(engine_name,last_api_error, "Reinstall Image")
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
      #      p failed(engine_name,engine.last_error,"Create")

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

#  def registerEngineWebSite engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","Register Engine Web Site")
#    end
#    retval =  engine.register_site()
#    if retval != true
#      return failed(engine_name,retval,"Register Engine Web Site")
#    end
#    return success(engine_name,"Register Engine Web Site")
#  end

  def restart_system
    if @core_api.restart_system == true
      return success("System","System Restarting")
    else
      return failed("System","not permitted","System Restarting")
    end
  end

  def update_engines_system_software
    if @core_api.update_engines_system_software == true
      p :update_engines_system_software
      return success("System","Engines System Updating")
    else
      return failed("System","not permitted","Engines System Updating")
    end
  end

  def update_system
    if @core_api.update_system == true
      p :update_system
      return success("System","System Updating")
    else
      return failed("System","not permitted","Updating")
    end
  end

#  def deregisterEngineWebSite engine_name
#    engine = loadManagedEngine engine_name
#    if  engine.is_a?(EnginesOSapiResult)
#      return failed(engine_name,"no Engine","DeRegister Engine Web Site")
#    end
#    retval =   engine.deregister_site()
#    if retval != true
#      return failed(engine_name,retval,"DeRegister Engine Web Site")
#    end
#    return success(engine_name,"DeRegister Engine Web Site")
#  rescue Exception=>e
#    return log_exception_and_fail("DeRegister Engine Web Site",e)
#  end

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
#
#  def get_volumes
#    vol_service = EnginesOSapi.loadManagedService("volmanager",@core_api)
#    if vol_service == nil
#      return failed("volmanager","No Such Service","get_volumes")
#    end
#    return vol_service.consumers
#  rescue Exception=>e
#    return log_exception_and_fail("get_volumes",e)
#  end
#
#  def get_databases
#    db_service = EnginesOSapi.loadManagedService("mysql_server",@core_api)
#    if db_service == nil
#      return failed("mysql_server","No Such Service","get_databases")
#    end
#    return db_service.consumers
#  end


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
      if engine == nil
        engine =  failed("set_engine_network_details",last_api_error,"set_engine_network_details")
      end
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

#  def create_ssl_certificate(params)
#    p params
#    #params[:default_cert]
#    #""default_domain"=>"engines.demo", "ssl_person_name"=>"test", "ssl_organisation_name"=>"test", "ssl_city"=>"test", "ssl_state"=>"test", "ssl_country"=>"AU"}
#    return success(params[:domain_name], "Add self hosted ssl cert domain")
#  end

  def update_domain(params)
    if @core_api.update_domain(params) == false
      return  failed(params[:domain_name],last_api_error, "update  domain")
    else
      return success(params[:domain_name], "update domain")
    end
  rescue Exception=>e
    return log_exception_and_fail("update self hosted domain " + params.to_s,e)
  end

  def add_domain params
    if @core_api.add_domain(params) == false
      return  failed(params[:domain_name],last_api_error, "Add  domain")
    else
      return success(params[:domain_name], "Add domain")
    end
  rescue Exception=>e
    return log_exception_and_fail("Add self hosted domain " + params.to_s,e)
  end

  def remove_domain params
    if @core_api.remove_domain(params) == false
      return  failed(params[:domain_name],last_api_error, "Add  domain")
    else
      return success(params[:domain_name], "Add domain")
    end
  rescue Exception=>e
    return log_exception_and_fail("Add self hosted domain " + params.to_s,e)
  end
  
  def list_domains
    return @core_api.list_domains( )
  rescue Exception=>e
    return log_exception_and_fail("list domains ",e)
  end

  #private ?
  #protected if protected static cant call
  def success(item_name ,cmd)
    return EnginesOSapiResult.success(item_name ,cmd)
  end

  def failed(item_name,mesg ,cmd)
    p :engines_os_api_fail_on
    p item_name
    p mesg
    p cmd
    mesg = mesg.to_s + ":" + last_api_error.to_s 
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
