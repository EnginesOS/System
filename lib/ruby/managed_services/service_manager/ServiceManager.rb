require 'rubytree'



require_relative '../../system_registry/SystemRegistry.rb'
require_relative '../../templater/Templater.rb'
require_relative '../../system/SystemAccess.rb'
class ServiceManager


  
  attr_accessor     :last_error
  #@ call initialise Service Registry Tree which conects to the registry server
  def initialize(core_api)
    @core_api = core_api   
    @system_registry = SystemRegistry.new(@core_api)
  end
  

  def is_service_persistant?(service_hash)
    if service_hash.has_key?(:persistant) == false
          persist = software_service_persistance(service_hash)
          if persist == nil
            log_error_mesg("Failed to get persistance status for ",service_hash)
            return false
          end
          service_hash[:persistant] = persist
        end
    service_hash[:persistant]
  end
    
  #load softwwareservicedefinition for serivce in service_hash and
  #@return boolean indicating the persistance
  #@return nil if no software definition found
  def software_service_persistance(service_hash)
    clear_last_error
    service_definition = software_service_definition(service_hash)
    if service_definition != nil && service_definition != nil
      return service_definition[:persistant]
    end
    return nil
  end
  
  
  #@ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  #@ All are added to the ManagesEngine/Service Tree
  #@ return true if successful or false if failed
  def add_service service_hash
    clear_last_error
    
    if service_hash[:variables].has_key?(:parent_engine) == false
      service_hash[:variables][:parent_engine] = service_hash[:parent_engine]
    end

    test_registry_result(@system_registry.add_to_managed_engines_registry(service_hash))

    if is_service_persistant?(service_hash) == true
      if add_to_managed_service(service_hash) == false
        log_error_mesg("Failed to create persistant service ",service_hash)
        return false
      end
      if test_registry_result(@system_registry.add_to_services_registry(service_hash)) == false
        log_error_mesg("Failed to add service to managed service registry",service_hash)
        return false
      end
    end

    return true

  rescue Exception=>e
    puts e.message
    log_exception(e)
    return false
  end

  def register_service_hash_with_service(service_hash)
    clear_last_error
    p :register_service_hash_with_service
    p service_hash
    if service_hash.has_key?(:service_container_name) == false
      service_hash[:service_container_name] = get_software_service_container_name(service_hash)
    end
    service = @core_api.loadManagedService( service_hash[:service_container_name])
    if service != nil && service != false
      return service.add_consumer_to_service(service_hash)
    end
    return false
  end

 

  #@returns boolean
  #load persistant and non persistant service definitions off disk and registers them
  def load_and_attach_services(dirname,container)
    clear_last_error
    envs = Array.new
    curr_service_file = String.new
    p :load_and_attach_services
    p dirname
    p container.container_name

    Dir.glob(dirname + "/*.yaml").each do |service_file|
      p "service_File"
      p service_file
      curr_service_file = service_file
      yaml = File.read(service_file)
      service_hash = YAML::load( yaml )
      service_hash = SystemUtils.symbolize_keys(service_hash)

      if service_hash.has_key?(:shared_service) == false || service_hash[:shared_service] == false
        ServiceManager.set_top_level_service_params(service_hash,container.container_name)
        if service_hash.has_key?(:container_type) == false
          service_hash[:container_type] = @core_api.container_type(service_hash[:parent_engine])
        end
        templater =  Templater.new(SystemAccess.new,container)
        templater.proccess_templated_service_hash(service_hash)
        SystemUtils.debug_output(  :templated_service_hash, service_hash)
        if service_hash[:persistant] == false || test_registry_result(@system_registry.service_is_registered?(service_hash)) == false
          add_service(service_hash)
        else
          service_hash =  test_registry_result(@system_registry.get_service_entry(service_hash))
        end
      else
        service_hash =  test_registry_result(@system_registry.get_service_entry(service_hash))
      end
      if service_hash.is_a?(Hash)
        SystemUtils.debug_output(  :post_entry_service_hash, service_hash)
        new_envs = SoftwareServiceDefinition.service_environments(service_hash)
        p "new_envs"
        p new_envs.to_s
        if new_envs != nil
          envs.concat(new_envs)
        end
      else
        log_error_mesg("failed to get service entry from " ,service_hash)
      end
    end
    return envs

  rescue Exception=>e
    puts e.message
    log_error_mesg("Parse error on " + curr_service_file,container)
    log_exception(e)
    return false
  end


#remove service matching the service_hash from both the managed_engine registry and the service registry
#@return false
def delete_service service_hash
  clear_last_error
  if remove_from_managed_service(service_hash) == false
    log_error_mesg("failed to remove managed service",service_hash)
    return false
  end
  return test_registry_result(@system_registry.remove_from_services_registry(service_hash))
end

def update_attached_service(params)
  clear_last_error
  p :update_attach_service_params
  p params
 if test_registry_result(@system_registry.update_attached_service(params)) == true   
   if remove_from_managed_service(params) == true
    return add_to_managed_service(params)
   else 
     @last_error="Filed to remove " + @system_registry.last_error 
   end
 else
   @last_error=@system_registry.last_error 
 end
 return false
 
end

  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine(params)
    clear_last_error
    services = test_registry_result(@system_registry.get_engine_persistant_services(params))
       services.each do | service |
         if params[:remove_all_data] == true
           if delete_service(service) == false
             log_error_mesg("Failed to remove service ",service)
             return false
           end
         else
           if orphan_service(service) == false
             log_error_mesg("Failed to orphan service ",service)
             return false
           end
         end
       end
   return test_registry_result(@system_registry.remove_from_managed_engines_registry(params))
  end
  
#def find_engine_services(params)
#  @system_registry.find_engine_services(params)
#end
   def find_engine_services_hashes(params)
     clear_last_error
     test_registry_result(@system_registry.find_engine_services_hashes(params))
   end
#


  def register_non_persistant_service(service_hash)
    clear_last_error
    if add_to_managed_service(service_hash) == false
      log_error_mesg("Failed to create persistant service ",service_hash)
      return false
    end

    if test_registry_result(@system_registry.add_to_services_registry(service_hash)) == false
      log_error_mesg("Failed to add service to managed service registry",service_hash)
      return false
    end

    return true
  end

  def deregister_non_persistant_service(service_hash)
    clear_last_error
    if remove_from_managed_service(service_hash) == false
      log_error_mesg("Failed to create persistant service ",service_hash)
      return false
    end

    if test_registry_result(@system_registry.remove_from_services_registry(service_hash)) == false
      log_error_mesg("Failed to deregsiter service from managed service registry",service_hash)
      return false
    end
    return true
  end

  #service manager get non persistant services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistant_services(engine)
    clear_last_error
    params = Hash.new()
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistant_services(params)
    services.each do |service_hash|
      register_non_persistant_service(service_hash)
    end

    return true
  end

  #service manager get non persistant services for engine_name
  #for each servie_hash load_service_container and remove hash
  #remove from service registry even if container is down
  def deregister_non_persistant_services(engine)
    clear_last_error
    params = Hash.new()
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistant_services(params)

    services.each do |service_hash|
      p :deregister_non_persistant_services
      p service_hash
      test_registry_result(@system_registry.remove_from_services_registry(service_hash))
      #      deregister_non_persistant_service(service_hash)
    end
    return true

  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    clear_last_error
    test_registry_result(@system_registry.get_registered_against_service(params))
   
  end

  #Calls remove service on the service_container to remove the service associated by the hash
  #@return result boolean
  #@param service_hash [Hash]
  #remove persistant services only if service is up
  def remove_from_managed_service(service_hash)
    clear_last_error
    service =  @core_api.load_software_service(service_hash)
    if service == nil
      log_error_mesg("Failed to load service to remove + " + @core_api.last_error,service_hash)
      return false
    end

    if service.is_running? == true || service.persistant == false
      if service.rm_consumer_from_service(service_hash) == true
        p service_hash
        return test_registry_result(@system_registry.remove_from_services_registry(service_hash))
      else
        @last_error= @system_registry.last_error
        p @last_error
        return false
      end
    elsif service.persistant == true
      log_error_mesg("Cant remove persistant service if service is stopped ",service_hash)
      return false
    else
      return true
    end

  end


def remove_service service_hash
  clear_last_error
   if test_registry_result(@system_registry.remove_from_services_registry(service_hash)) == false
     log_error_mesg("failed to remove from service registry",service_hash)
     return false
   end
   SystemUtils.debug_output(  :remove_service, service_hash)
   return true

 rescue Exception=>e
   if service_hash != nil
     p service_hash
   end
   log_exception(e)
   return false
 end

 #@ removes underly service and remove entry from orphaned services
 #@returns boolean indicating success
 def remove_orphaned_service(service_hash)
   clear_last_error
      if remove_from_managed_service(service_hash) == false
         log_error_mesg("failed to remove managed service:" +  @system_registry.last_error,service_hash)
         return false
       end
   return release_orphan(service_hash)
 end

 
  #Calls on service on the service_container to add the service associated by the hash
  #@return result boolean
  #@param service_hash [Hash]
  def add_to_managed_service(service_hash)
    clear_last_error
    service =  @core_api.load_software_service(service_hash)
    if service == nil || service == false
      log_error_mesg("Failed to load service to remove :" +  @system_registry.last_error,service_hash)
      return false
    end
    if service.is_running? == false
      log_error_mesg("Cant add to service if service is stopped ",service_hash)
      return false
    end
    result =  service.add_consumer_to_service(service_hash)
    if result == false
      log_error_mesg("Failed to add Consumser to Service :" +  @system_registry.last_error + service.last_error)
    end
    return result
  end
  


  #Find the assigned service container_name from teh service definition file
   def get_software_service_container_name(params)
     clear_last_error
     server_service =  software_service_definition(params)
     if server_service == nil || server_service == false
       log_error_mesg("Failed to load service definitions",params)
       return nil
     end
     return server_service[:service_container] 
   end

  
  #@return [Array] of service hash for ObjectName matching the name  identifier
   #@objectName [String]
   #@identifier [String]
   def list_attached_services_for(objectName,identifier)
     clear_last_error
     p :services_on_objects_4
     SystemUtils.debug_output("services_on_objects_",objectName)
     SystemUtils.debug_output("services_on_objects_",identifier)
 
     params = Hash.new
 
     case objectName
     when "ManagedEngine"
       params[:parent_engine] = identifier
       SystemUtils.debug_output(  :get_engine_service_hashes,"ManagedEngine")
 #      hashes = @system_registry.find_engine_services_hashes(params)
 #      SystemUtils.debug_output("hashes",hashes)
 
       return test_registry_result(@system_registry.find_engine_services_hashes(params))
       #    attached_managed_engine_services(identifier)
     when "Volume"
       SystemUtils.debug_output(  :looking_for_volume,identifier)
       return attached_volume_services(identifier)
     when "Database"
       SystemUtils.debug_output(  :looking_for_database,identifier)
       return attached_database_services(identifier)
     end
     p :no_object_name_match
     p objectName
 
     return nil
 
   rescue Exception=>e
     puts e.message
     log_exception(e)
 
     return nil
 
   end
  
  #@return [Hash] of [SoftwareServiceDefinition] that Matches @params with keys :type_path :publisher_namespace
  def software_service_definition(params)
    clear_last_error
    return  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )

  rescue Exception=>e
    p :error
    p params

    log_exception(e)
    return nil
  end 
  
  def ServiceManager.set_top_level_service_params(service_hash,container_name)
 
     if service_hash == nil
       log_error_mesg("no set_top_level_service_params_nil_service_hash container_name:",container_name)
       return false
     end
     if container_name == nil
       log_error_mesg("no set_top_level_service_params_nil_container_name service_hash:",service_hash)
       return false
     end
     service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
     if service_def  == nil
       SystemUtils.log_error_mesg("no service_def for",service_hash)
       return nil
     end
     if service_def.has_key?(:service_handle_field) && service_def[:service_handle_field] !=nil
       handle_field_sym = service_def[:service_handle_field].to_sym
     end
 
     service_hash[:persistant] = service_def[:persistant]
 
     service_hash[:parent_engine]=container_name
 
     if service_hash.has_key?(:variables) == false
       service_hash[:variables] = Hash.new
     end
     service_hash[:variables][:parent_engine]=container_name
 
     if service_hash.has_key?(:service_handle) == false || service_hash[:service_handle] == nil
       if handle_field_sym != nil && service_hash[:variables].has_key?(handle_field_sym) == true  && service_hash[:variables][handle_field_sym] != nil
         service_hash[:service_handle] = service_hash[:variables][handle_field_sym]
       else
         service_hash[:service_handle] = container_name
       end
     end
 
   end
   
#test the result and carry last_error from @system_registry if result nil
#@return result  
def test_registry_result(result)
  clear_last_error
  if result == nil
    @last_error=@system_registry.last_error      
  end
  return result
end


#test the result and carry last_error from @system_registry if nil
#freeze result object if not nil
#@return result
def test_and_lock_registry_result(result)
  if test_registry_result(result) != nil
    result.freeze
  end
end

def update_service_configuration(config_hash)      
  #load service definition and from configurators definition and if saveable save
  service_definition = software_service_definition(config_hash)
   if service_definition.is_a?(Hash) == false
     @last_error= "Missing Service definition file"
     return false
   end
   if  configurator_definition.has_key?(:configurator_name)  == false
     @last_error= "Missing Configurator name"
         return false
       end
       
    configurator_definition = service_definition[:configurators][config_hash[:configurator_name].to_sym]
test_registry_result(@system_registry.update_service_configuration(config_hash))
    if configurator_definition.has_key?(:no_save) == false ||  configurator_definition[:no_save] == false
      return test_registry_result(@system_registry.update_service_configuration(config_hash))
    else
      return true
    end
rescue Exception=>e
  log_exception(e)  
    end

###READERS 

#list the Provider namespaces as an Array of Strings
#@return [Array]
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def list_providers_in_use
  test_and_lock_registry_result(@system_registry.list_providers_in_use)
end

#@return [Tree::TreeNode] representing the orphaned services tree as dettached and frozen from the parent Tree
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def get_orphaned_services_tree      
  test_and_lock_registry_result(@system_registry.orphaned_services_registry)
end

#@return [Tree::TreeNode] representing the managed services tree as dettached and frozen from the parent Tree
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def managed_service_tree
  test_and_lock_registry_result(@system_registry.services_registry)      
end

#@return [Tree::TreeNode] representing the managed engines tree as dettached and frozen from the parent Tree
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def get_managed_engine_tree      
  test_and_lock_registry_result(@system_registry.managed_engines_registry)
 end
 
#@return [Tree::TreeNode] representing the services configuration tree as dettached and frozen from the parent Tree
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def service_configurations_tree      
  test_and_lock_registry_result(@system_registry.service_configurations_registry)
end
  
#@return an [Array] of service_hashs of Orphaned persistant services matching @params [Hash]
# required keys
# :publisher_namespace
# optional 
#:path_type 
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
#on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method 
def get_orphaned_services(params)    
  test_and_lock_registry_result(@system_registry.get_orphaned_services(params))
end 

#@return [Array] of all service_hashs marked persistance false for :engine_name
# required keys
# :engine_name
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method   
#on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method 
def get_engine_nonpersistant_services(params)      
  test_registry_result(@system_registry.get_engine_nonpersistant_services(params))
end

#@return [Array] of all service_hashs marked persistance true for :engine_name
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
#on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method 
def get_engine_persistant_services(params)      
  test_registry_result(@system_registry.get_engine_persistant_services(params))
end 
 
#@Returns an Array of Configuration hashes resgistered against the service [String] service_name
#@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method 
def get_service_configurations_hashes(service_name)      
  test_registry_result(@system_registry.get_service_configurations_hashes(service_name))
end

#Test whether a service hash is registered
#@return's false on failure with error (if applicable) accessible from this object's  [ServiceManager] last_error method 
def service_is_registered?(service_hash)      
    result = test_registry_result(@system_registry.service_is_registered?(service_hash))
      if result == nil
        return false
      end
      return result      
end
  

def orphanate_service(params)      
  test_registry_result(@system_registry.orphanate_service(params))
end

def retrieve_orphan(params)      
  test_registry_result(@system_registry.retrieve_orphan(params))
end

def rebirth_orphan(params)      
  test_registry_result(@system_registry.rebirth_orphan(params))
end
  
#def reparent_orphan(params)      
#  test_registry_result(@system_registry.reparent_orphan(params))
# end

 
  #Appends msg + object.to_s (truncated to 256 chars) to @last_log
  #Calls SystemUtils.log_error_msg(msg,object) to log the error
  #@return none
  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)    
    @last_error = @last_error.to_s + ":" + msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)
  end
 
  #@Resets last_error to nil
  def    clear_last_error
    @last_error=nil
  end
  
  #@Log Exception and add exception to last_error
  def log_exception(e)
    @last_error = @last_error.to_s + ":" + e.to_s.slice(0,256)
    SystemUtils.log_exception(e)
    return false
  end
end
