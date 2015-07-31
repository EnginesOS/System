require 'rubytree'

#require_relative 'service_manager_tree.rb'
#include ServiceManagerTree
#require_relative 'orphaned_services.rb'
#include OrphanedServices
#require_relative 'managed_engines_registry.rb'
#include ManagedEnginesRegistry
#require_relative 'services_registry.rb'
#include ServicesRegistry
#require_relative 'service_configurations.rb'
#include ServiceConfigurations
require_relative '../system_registry/Registry.rb'
require_relative '../system_registry/SystemRegistry.rb'
require_relative '../../templater/Templater.rb'
require_relative '../../system/SystemAccess.rb'
class ServiceManager

  #@service_tree root of the Service Registry Tree
  attr_accessor     :last_error
  #@ call initialise Service Registry Tree which loads it from disk or create a new one if none exits
  def initialize(core_api)
    @core_api = core_api
    #@service_tree root of the Service Registry Tree
    #@service_tree = initialize_tree
    @system_registry = SystemRegistry.new()
  end
  def get_orphaned_services(params)
    @system_registry.get_orphaned_services(params)
  end
  
  def get_orphaned_services_tree
    @system_registry.orphaned_services_registry
  end
  def get_engine_nonpersistant_services(params)
    @system_registry.get_engine_nonpersistant_services(params)
  end
  
  def managed_service_tree
    @system_registry.services_registry
  end
  def get_managed_engine_tree
     @system_registry.managed_engines_registry
   end
  def service_configurations_tree
    @system_registry.service_configurations_registry
  end
  #Find the assigned service container_name from teh service definition file
  def get_software_service_container_name(params)

    server_service =  software_service_definition(params)

    if server_service == nil || server_service == false
      log_error_mesg("Failed to load service definitions",params)
      return nil
    end
    return server_service[:service_container]

  end

  #list the Provider namespaces as an Array of Strings
  #@return [Array]
  def list_providers_in_use
    @system_registry.list_providers_in_use

  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def delete_service service_hash
    @system_registry.delete_service service_hash  
  end

 

  #@return [Array] of service hash for ObjectName matching the name  identifier
  #@objectName [String]
  #@identifier [String]
  def list_attached_services_for(objectName,identifier)
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

      return @system_registry.find_engine_services_hashes(params)
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
  #

  #load softwwareservicedefinition for serivce in service_hash and
  #@return boolean indicating the persistance
  #@return nil if no software definition found
  def software_service_persistance(service_hash)
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

    if service_hash.has_key?(:persistant) == false
      persist = software_service_persistance(service_hash)
      if persist == nil
        log_error_mesg("Failed to get persistance status for ",service_hash)
        return false
      end
      service_hash[:persistant] = persist
    end
    if service_hash[:variables].has_key?(:parent_engine) == false
      service_hash[:variables][:parent_engine] = service_hash[:parent_engine]
    end

    @system_registry.add_to_managed_engines_registry(service_hash)

    if service_hash[:persistant] == true
      if add_to_managed_service(service_hash) == false
        log_error_mesg("Failed to create persistant service ",service_hash)
        return false
      end
      if @system_registry.add_to_services_registry(service_hash) == false
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

  #@returns boolean
  #load persistant and non persistant service definitions off disk and registers them
  def load_and_attach_services(dirname,container)
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
        if service_hash[:persistant] == false || @system_registry.service_is_registered?(service_hash) == false
          add_service(service_hash)
        else
          service_hash =  @system_registry.get_service_entry(service_hash)
        end
      else
        service_hash =  @system_registry.get_service_entry(service_hash)
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



  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine(params)
    @system_registry.rm_remove_engine(params)
    
  end

  #@returns boolean indicating sucess
  #Saves service_hash in orphan registry before removing from service registry
  def orphan_service(service_hash)
    if @system_registry.save_as_orphan(service_hash)
      return  remove_service(service_hash)
    end
    log_error_mesg("Failed to save orphan",service_hash)

    return false
  end

  #@return [Hash] of [SoftwareServiceDefinition] that Matches @params with keys :type_path :publisher_namespace
  def software_service_definition(params)

    return  SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )

  rescue Exception=>e
    p :error
    p params

    log_exception(e)
    return nil
  end

  def register_non_persistant_service(service_hash)

    if add_to_managed_service(service_hash) == false
      log_error_mesg("Failed to create persistant service ",service_hash)
      return false
    end

    if @system_registry.add_to_services_registry(service_hash) == false
      log_error_mesg("Failed to add service to managed service registry",service_hash)
      return false
    end

    return true
  end

  def deregister_non_persistant_service(service_hash)

    if remove_from_managed_service(service_hash) == false
      log_error_mesg("Failed to create persistant service ",service_hash)
      return false
    end

    if @system_registry.remove_from_services_registry(service_hash) == false
      log_error_mesg("Failed to deregsiter service from managed service registry",service_hash)
      return false
    end
    return true
  end

  #service manager get non persistant services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistant_services(engine)

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
    params = Hash.new()
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistant_services(params)

    services.each do |service_hash|
      @system_registry.remove_from_services_registry(service_hash)
      #      deregister_non_persistant_service(service_hash)
    end
    return true

  end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    @system_registry.get_registered_against_service(params)
   
  end

  #Calls remove service on the service_container to remove the service associated by the hash
  #@return result boolean
  #@param service_hash [Hash]
  #remove persistant services only if service is up
  def remove_from_managed_service(service_hash)
    service =  @core_api.load_software_service(service_hash)
    if service == nil
      log_error_mesg("Failed to load service to remove ",service_hash)
      return false
    end

    if service.is_running? == true || service.persistant == false
      if service.rm_consumer_from_service(service_hash) == true
        @system_registry.remove_from_engine_registery(service_hash)
      end
    elsif service.persistant == true
      log_error_mesg("Cant remove persistant service if service is stopped ",service_hash)
      return false
    else
      return true
    end

  end
  
#def managed_service_tree()
#    return _managed_service_tree()
#end
#def find_engine_services_hashes(params)
#  _find_engine_services_hashes(params)
#end
#def  get_managed_engine_tree
#  return _get_managed_engine_tree
#end
#def retrieve_orphan(params)
#  
#  return _retrieve_orphan(params)
#end
#def get_engine_persistance_services(params,persistance)
#  return _get_engine_persistance_services(params,persistance)
#end
#
##@return [Array] of all service_hashs marked persistant for :engine_name
#def get_engine_persistant_services(params)
#  return _get_engine_persistance_services(params,true)
#end
#
##@return [Array] of all service_hashs not marked persistant for :engine_name
#def get_engine_nonpersistant_services(params)
#  return _get_engine_persistance_services(params,false)
#end
#
#def service_is_registered?(service_hash)
#  _service_is_registered?(service_hash)
#end
#def release_orphan(params)
#  
#  return _release_orphan(params)
#end
#
#def reparent_orphan(params)
#  return _reparent_orphan(params)
#  end
#  
#def get_orphaned_services(params)
#  return _get_orphaned_services(params)
#end
#
#def get_orphaned_services_tree  
#  return _orphaned_services_tree
#end
#
#def service_configurations_tree
#  _service_configurations_tree
#end
#
#def orphaned_services_tree  
#  return _orphaned_services_tree
#end
#
#def services_tree_of_orphaned_services
#  get_orphaned_services
#  return _orphaned_services_tree
#end

##module ServiceConfigurations
#  
#  #@ return an [Array] of Service Configuration [Hash]es of all the service configurations for [String] service_name
#  def get_service_configurations(service_name)    
#    if  service_configurations_tree.is_a?(Tree::TreeNode) == false
#      return false
#     end
#    service_configurations = service_configurations_tree[service_name]
#    
#    if service_configurations.is_a?(Tree::TreeNode)
#      return service_configurations     
#    end
#    return false
#  end
#
#  def get_service_configurations_hashes(service_name)
#    configurations = get_service_configurations(service_name)
#    if  configurations.is_a?(Tree::TreeNode) == false
#      p "no service configurations for " + service_name.to_s
#      return Array.new
#    else
#      leafs = get_all_leafs_service_hashes(configurations)
#      p "leafs are " +  leafs.to_s
#      return leafs
#  end
#  
#  end
#  
#  #@ return a service_configuration_hash addressed by :service_name :configuration_name
#  
#  def get_service_configuration(service_configuration_hash)
#
#    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
#    if service_configurations.is_a?(Tree::TreeNode) == false
#      return false
#    end
#    
#    if service_configuration_hash.has_key?(:configurator_name) == false     
#            return get_all_leafs_service_hashes(service_configurations)
#    end
#    
#      service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
#      if service_configuration.is_a?(Tree::TreeNode)
#        return service_configuration.content
#    end
#    return false
#  end
#  
#  def add_service_configuration(service_configuration_hash)
#    configurations = get_service_configurations(service_configuration_hash[:service_name])
#    if configurations.is_a?(Tree::TreeNode) == false
#      configurations = Tree::TreeNode.new(service_configuration_hash[:service_name] ," Configurations for :" + service_configuration_hash[:service_name]  )
#      service_configurations_tree << configurations
#    elsif configurations[service_configuration_hash[:configurator_name]]
#      p :service_configuration_hash_exists
#      p service_configuration_hash.to_s
#      return false
#    end
#      configuration = Tree::TreeNode.new(service_configuration_hash[:configurator_name],service_configuration_hash)
#      configurations << configuration
#p "add " + service_configuration_hash.to_s
#      save_tree
#    
#  end
#  
#  def rm_service_configuration(service_configuration_hash)
#    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
#        if service_configurations.is_a?(Tree::TreeNode) == false
#          p :serivce_configurations_not_found
#          return false
#        end
#        
#        if service_configuration_hash.has_key?(:configurator_name) == false
#          p :no_configuration_name     
#                return false
#        end
#        
#          service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
#          if service_configuration.is_a?(Tree::TreeNode)
#            remove_tree_entry(service_configuration)
#            save_tree
#           return true
#        end
#        return false
#  end
#  
#  def update_service_configuration(service_configuration_hash)
#    service_configurations = get_service_configurations(service_configuration_hash[:service_name])  
#            if service_configurations.is_a?(Tree::TreeNode) == false
#              p :serivce_configurations_not_found
#              return add_service_configuration(service_configuration_hash)
#              #return false
#            end
#            
#            if service_configuration_hash.has_key?(:configurator_name) == false
#              p :no_configuration_name     
#              return  false 
#              
#            end
#            
#              service_configuration = service_configurations[service_configuration_hash[:configurator_name]]
#              if service_configuration.is_a?(Tree::TreeNode)
#                service_configuration.content = service_configuration_hash
#                p "saved " + service_configuration_hash.to_s
#                save_tree
#               return true
#              else
#                return add_service_configuration(service_configuration_hash)
#            end
#
#            return false
#    end
#  
##end

def remove_service service_hash
   if @system_registry.remove_from_services_registry(service_hash) == false
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
   #    if remove_from_managed_service(service_hash) == false
   #      log_error_mesg("failed to remove managed service",service_hash)
   #      return false
   #    end
   return release_orphan(service_hash)
 end
 
  #Calls on service on the service_container to add the service associated by the hash
  #@return result boolean
  #@param service_hash [Hash]
  def add_to_managed_service(service_hash)
    service =  @core_api.load_software_service(service_hash)
    if service == nil || service == false
      log_error_mesg("Failed to load service to remove ",service_hash)
      return false
    end

    if service.is_running? == false
      log_error_mesg("Cant add to service if service is stopped ",service_hash)
      return false
    end

    return service.add_consumer_to_service(service_hash)
  end

  #Sets @last_error to msg + object.to_s (truncated to 256 chars)
  #Calls SystemUtils.log_error_msg(msg,object) to log the error
  #@return none
  def log_error_mesg(msg,object)
    obj_str = object.to_s.slice(0,256)

    @last_error = msg +":" + obj_str
    SystemUtils.log_error_mesg(msg,object)

  end

  def log_exception(e)
    @last_error = e.to_s.slice(0,256)
    SystemUtils.log_exception(e)
  end
end
