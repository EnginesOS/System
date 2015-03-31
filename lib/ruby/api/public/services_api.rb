module ServicesApi
  
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
      return self.failed(service_name,core_api.last_error ,"Load Service")
    end
    return service
  rescue Exception=>e
    return self.log_exception_and_fail("LoadMangedService",e)
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
  
  def attach_service(params)
    if  @core_api.attach_service(params) == true
      success(params[:parent_engine],"attach service")
    else
      return failed(params[:parent_engine],core_api.last_error ,params[:parent_engine])
    end
  end
  
  def get_service_definition(service_type,service_provider)
      #Fixme ignoring service_provider
      
      return SoftwareServiceDefinition.find(service_type,service_provider)
    end
    
    def detach_service(params)
      if   @core_api.dettach_service(params)== true
        success(params[:parent_engine],"detach service")
      else
        return failed(params[:parent_engine],core_api.last_error ,params[:parent_engine])
      end
      end
      
    def get_managed_engine_tree
      return @core_api.get_managed_engine_tree  
    end
    
    def managed_service_tree
      return @core_api.managed_service_tree
    end
  
    def get_orphaned_services_tree
    return @core_api.get_orphaned_services_tree
    end
    
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
    
    def load_avail_services_for_type(typename)
      return  @core_api.load_avail_services_for_type(typename)
      
    end
    def list_attached_services_for(object_name,identifier)
      SystemUtils.debug_output("list_attached_services_for",object_name + " " + identifier)
      attached = @core_api.list_attached_services_for(object_name,identifier)
      p :found_attached
     # p attached
       return @core_api.list_attached_services_for(object_name,identifier)
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
 
   
  
end