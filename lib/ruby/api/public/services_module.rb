module ServicesModule
  
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
    
  def list_services()
    return @core_api.list_managed_services
  rescue Exception=>e
    return log_exception_and_fail("list_services",e)
  end
  
  def getManagedServices()
    return @core_api.getManagedServices()
  rescue Exception=>e
    return log_exception_and_fail("getManagedServices",e)
  end
  
  def self.loadManagedService(service_name,core_api)
     service = core_api.loadManagedService(service_name)
     if service == false
       return EnginesOSapi.failed(service_name,core_api.last_error ,"Load Service")
     end
     return service
   rescue Exception=>e
     return EnginesOSapi.log_exception_and_fail("LoadMangedService",e)
   end
   
 
  def getManagedService(service_name)
 
     managed_service = ServicesModule.loadManagedService(service_name,@core_api)
     #  if managed_service == nil
     #   return failed(service_name,"Fail to Load configuration:","Load Service")
     #end
     return managed_service
   rescue Exception=>e
     return log_exception_and_fail("getManagedService",e)
   end
   
  def list_avail_services_for(object)
    return @core_api.list_avail_services_for(object)
  end
  
  
  def find_service_consumers(params)
    p params
    return @core_api.find_service_consumers(params)
  end
  
  def get_engine_persistant_services(params)
    return @core_api.get_engine_persistant_services(params)
  end
  
  #@returns [EnginesOSapiResult]
  #expects a service_hash as @params
  def attach_service(params)
    if params.has_key?(:service_handle) == false
      params[:service_handle] = params[:variables][:name]
    end
    if  @core_api.attach_service(params) == true
      success(params[:parent_engine],"attach service")
    else
      return failed(params[:parent_engine],core_api.last_error ,params[:parent_engine])
    end
  end
  
  #@ retruns [SoftwareServiceDefinition] 
  #for type_path [String] and service_provider[String]
  def get_service_definition(type_path,service_provider)
      #Fixme ignoring service_provider
      
      return SoftwareServiceDefinition.find(type_path,service_provider)
    end
    
  #@returns [EnginesOSapiResult]
  #expects a service_hash as @params
    def detach_service(params)
      if   @core_api.dettach_service(params)== true
        success(params[:parent_engine].to_s,"detach service")
      else
        return failed(params[:parent_engine].to_s,core_api.last_error ,params[:parent_engine].to_s)
      end
      end
      
    #@ return [EnginesOSapiResult]
      #@params service_hash
      #this method is called to register the service hash with service
      #nothing is written to the service registry
      #effectivitly activating non persistant services
   def register_service(service_hash)
     return success(service_hash[:parent_engine].to_s + " " +service_hash[:service_handle].to_s ,"Register Service")
   end
  #@ return [EnginesOSapiResult]
    #@params service_hash
    #this method is called to deregister the service hash from service
    #nothing is written to the service resgitry   
   def deregister_service(service_hash)
     return success(service_hash[:parent_engine].to_s + " " +service_hash[:service_handle].to_s ,"Deregister Service")
   end
  #@ return [EnginesOSapiResult]
      #@params service_hash
      #this method is called to deregister the service hash from service
     # and then to register the service_hash with the service
      #nothing is written to the service resgitry   
   def reregister_service(service_hash)
    if  deregister_service(service_hash).was_success
      return register_service(service_hash)
    end
     return success(service_hash[:parent_engine].to_s + " " +service_hash[:service_handle].to_s ,"reregister Service")
   end
      
    def get_managed_engine_tree
      return @core_api.get_managed_engine_tree  
    end
  
    def managed_service_tree
      return fetch_managed_service_tree
    end  
    def fetch_managed_service_tree
      p :managed_service_tree
      return @core_api.managed_service_tree
    end
    
  def get_orphaned_services_tree
  return @core_api.get_orphaned_services_tree
  end
  
  #@return  an [Array] of service_hashes regsitered against the Service named service name
  #wrapper for gui programs calls get_registered_against_service(params)
  def registered_engines_on_service(service_name)
    service = getManagedService(service_name)
    if service == nil || service.is_a?(EnginesOSapiResult)
      return failed(service_name,"No Such Service","list registered Service")
    end
    params =  Hash.new
    params[:type_path]= service.type_path
      params[:publisher_namespace]= service.publisher_namespace
    return @core_api.get_registered_against_service(params)
    
  end  
    
  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
    def get_registered_against_service(params)
      return @core_api.get_registered_against_service(params)
    end

    #@return an [Array] of service_hashs of Active persistant services match @params [Hash]
    #:path_type :publisher_namespace    
    def get_active_persistant_services(params)
      return @core_api.get_active_persistant_services(params)
    end
    
  #@return an [Array] of service_hashs of Orphaned persistant services match @params [Hash]
  #:path_type :publisher_namespace      
    def get_orphaned_services(params)
      return @core_api.get_orphaned_services(params)
    end
    
  #@ retruns [SoftwareServiceDefinition] 
   #for params :type_path :publisher_namespace
    def software_service_definition (params)
      retval = @core_api.software_service_definition(params)
      if retval != nil
        return retval
      end 
      p :error_software_service_definition 
      p params
       return failed(params[:type_path] + ":" + params[:publisher_namespace] ,@core_api.last_error,"get software_service_definition")
    end
    
    #protected if protected static cant call
    def success(item_name ,cmd)
      return EnginesOSapiResult.success(item_name ,cmd)
    end
  
    def list_services_for(object)
      return @core_api.list_services_for(object)
    end
    
    def attach_subservice(params)
      #service params and component objectname / and component name and parent name    
    end
    
    def detach_subservice(params)
    end
    
  
  def delete_orphaned_service(params)
    
    if @core_api.remove_orphaned_service(params) == true
      return success(params[:service_handle],"Delete Service")    
     else
      SystemUtils.log_error_mesg("Delete Orphan Service",params)
      return failed(params[:service_handle],@core_api.last_error,"Delete Orphan Service")
    end
   
    rescue Exception=>e
       return log_exception_and_fail("Orphan",e)
   
  end
  
    def load_avail_services_for_type(typename)
      return  @core_api.load_avail_services_for_type(typename)
      
    end
    def list_attached_services_for(object_name,identifier)
      SystemUtils.debug_output("list_attached_services_for",object_name + " " + identifier)
      attached = @core_api.list_attached_services_for(object_name,identifier)
#      p :found_attached
     # p attached
       return @core_api.list_attached_services_for(object_name,identifier)
     end
#  def registerServiceDNS service_name
#     service =getManagedService(service_name)
#     if service == nil
#       return  failed(service_name,service.last_error,"Register Service DNS")
#     end
# 
#     if service.is_a?(EnginesOSapiResult)
#       return service
#     end
# 
#     retval =   service.register_dns()
# 
#     if retval != true
#       return failed(service_name,retval,"Register Service DNS")
#     end
#     return success(service_name,"Register Service DNS")
#   rescue Exception=>e
#     return log_exception_and_fail("Register Service DNS",e)
#   end
# 
#   def deregisterServiceDNS service_name
#     service =getManagedService(service_name)
#     if service == nil
#       return  failed(service_name,service.last_error,"Deregister Service DNS")
#     end
# 
#     if service.is_a?(EnginesOSapiResult)
#       return service
#     end
# 
#     retval =   service.deregister_dns()
#     if retval != true
#       return failed(service_name,retval,"Deregister Service DNS")
#     end
#     return success(service_name,"Deregister Service DNS")
#   rescue Exception=>e
#     return log_exception_and_fail("DeRegister Service DNS",e)
#   end
 
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
 
#   def registerServiceWebSite service_name
#     service = getManagedService(service_name)
#     if service == nil
#       return failed(service_name,"No Such Service","Register Service Web")
#     end
# 
#     if service.is_a?(EnginesOSapiResult)
#       return service
#     end
# 
#     retval =   service.register_site()
#     if retval != true
#       return failed(service_name,service.last_error,"Register Service Web")
#     end
#     return success(service_name,"Register Service Web")
#   rescue Exception=>e
#     return log_exception_and_fail("Register Service Web",e)
#   end
# 
#   def deregisterServiceWebSite service_name
#     service =getManagedService(service_name)
#     if service == nil
#       return  failed(service_name,"No Such Service","Deregister Service Web")
#     end
# 
#     if service.is_a?(EnginesOSapiResult)
#       return service
#     end
# 
#     retval =   service.deregister_site()
#     if retval != true
#       return failed(service_name,service.last_error,"Deregister Service Web")
#     end
#     return success(service_name,"Deregister Service Web")
#   rescue Exception=>e
#     return log_exception_and_fail("DeRegister Service Web",e)
#   end

  def get_available_services_for(item)
     res = @core_api.get_available_services_for(item)
      if res != nil
        return res
           else
             return failed("get avaiable services ",last_api_error,"get avaiable services")
           end
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
    
  def set_service_hostname_properties(params)
      return success(params[:engine_name],"update service hostname params")
         rescue Exception=>e
             return log_exception_and_fail("set_engine_hostname_details ",e)
    end
 
    
end