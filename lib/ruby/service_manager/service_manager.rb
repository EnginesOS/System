require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'
require_relative 'service_definitions.rb'

require '/opt/engines/lib/ruby/system/system_utils.rb'
class ServiceManager  < ErrorsApi

  require_relative 'service_actions.rb'
#  require_relative 'service_definitions.rb'
#  include ServiceDefinitions
 
  
  #@ call initialise Service Registry Tree which conects to the registry server
  def initialize(core_api)
    @core_api = core_api
    @system_registry = SystemRegistryClient.new(@core_api)
  end

  def get_service_entry(service_hash)
     test_registry_result(@system_registry.get_service_entry(service_hash))
   end
   

 
  #@ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  #@ All are added to the ManagesEngine/Service Tree
  #@ return true if successful or false if failed
  def add_service(service_hash)
    clear_error
    p :pre_top_level
    p service_hash
    service_hash[:variables][:parent_engine] = service_hash[:parent_engine] unless service_hash[:variables].has_key?(:parent_engine)
    ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
      p :potst_top_level
      p service_hash
    test_registry_result(@system_registry.add_to_managed_engines_registry(service_hash))
      return true if service_hash.key?(:shared) && service_hash[:shared] == true
    if ServiceDefinitions.is_service_persistant?(service_hash)      
      return log_error_mesg('Failed to create persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))
    else
      return log_error_mesg('Failed to create non persistant service ',service_hash) unless add_to_managed_service(service_hash)
      return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))    
    end
    return true
  rescue Exception=>e
    puts e.message
    log_exception(e)
  end

  #@returns boolean
  #load persistant and non persistant service definitions off disk and registers them
  def load_and_attach_services(dirname,container)
    clear_error
    envs = []
    curr_service_file = ''
    Dir.glob(dirname + '/*.yaml').each do |service_file|
      curr_service_file = service_file
      yaml = File.read(service_file)
      service_hash = YAML::load( yaml )
      service_hash = SystemUtils.symbolize_keys(service_hash)
      service_hash[:container_type] = container.ctype 
    
      
      ServiceDefinitions.set_top_level_service_params(service_hash, container.container_name)
      if service_hash.has_key?(:shared_service) == false || service_hash[:shared_service] == false      
        templater =  Templater.new(SystemAccess.new,container)
        templater.proccess_templated_service_hash(service_hash)
        SystemUtils.debug_output(  :templated_service_hash, service_hash)
        if service_hash[:persistant] == false || test_registry_result(@system_registry.service_is_registered?(service_hash)) == false
          add_service(service_hash)
        else
          service_hash =  test_registry_result(@system_registry.get_service_entry(service_hash))
        end
      else
         p :finding_service_to_share
         p service_hash
        service_hash = test_registry_result(@system_registry.get_service_entry(service_hash))
          p :load_share_hash
          p service_hash
      end
      if service_hash.is_a?(Hash)
        SystemUtils.debug_output(  :post_entry_service_hash, service_hash)
        new_envs = SoftwareServiceDefinition.service_environments(service_hash)
        p 'new_envs'
        p new_envs.to_s
        envs.concat(new_envs) if !new_envs.nil?
      else
        log_error_mesg('failed to get service entry from ' ,service_hash)
      end
    end
    return envs
  rescue Exception=>e
    puts e.message
    log_error_mesg('Parse error on ' + curr_service_file,container)
    log_exception(e)
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  #@return false
  def delete_service(service_query)
    clear_error
    complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
    service_hash = @system_registry.find_engine_service_hash(complete_service_query)    
    return log_error_mesg('Failed to match params to registered service',service_hash) unless service_hash
    service_hash[:remove_all_data] = service_query[:remove_all_data]
    return log_error_mesg('failed to remove from managed service',service_hash) unless remove_from_managed_service(service_hash) || service_query[:force].key?
    return remove_engine_from_managed_engines_registry(service_hash) if test_registry_result(@system_registry.remove_from_services_registry(service_hash))
    return log_error_mesg('failed to remove managed service from services registry', service_hash)
    rescue StandardError => e
      log_exception(e)
  end

  def update_attached_service(params)
    clear_error
    ServiceDefinitions.set_top_level_service_params(params,params[:parent_engine])
    if test_registry_result(@system_registry.update_attached_service(params))
      return add_to_managed_service(params)  if remove_from_managed_service(params)
         # this calls add_to_managed_service(params) plus adds to reg
        @last_error='Filed to remove ' + @system_registry.last_error.to_s
    else
      @last_error = @system_registry.last_error.to_s
    end
    return false  
    rescue StandardError => e
      log_exception(e)
  end

 
  #@ remove an engine matching :engine_name from the service registry, all non persistant serices are removed
  #@ if :remove_all_data is true all data is deleted and all persistant services removed
  #@ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  #@return true on success and false on fail
  def rm_remove_engine_services(params)
    p :rm_remove_engine_services
    clear_error
    p params
    services = test_registry_result(@system_registry.get_engine_persistant_services(params))
      p :persistant_services
      p services
    services.each do | service |      
      if params[:remove_all_data] && service.key?(:shared) && service[:shared]
        service[:remove_all_data] = params[:remove_all_data]
        unless delete_service(service)
         log_error_mesg('Failed to remove service ',service)
         next         
        end
      else
        unless orphanate_service(service)
        log_error_mesg('Failed to orphan service ',service)
        next
        end 
      end
      @system_registry.remove_from_managed_engines_registry(service)      
    end
    return true 
    rescue StandardError => e
      log_exception(e)
  end
 
  
  #def find_engine_services(params)
  #  @system_registry.find_engine_services(params)
  #end
  def find_engine_services_hashes(params)
    clear_error
    test_registry_result(@system_registry.find_engine_services_hashes(params))
  end
  #
  
  def find_engine_service_hash(params)
      clear_error
      test_registry_result(@system_registry.find_engine_service_hash(params))
    end

 
  def register_non_persistant_service(service_hash)
      ServiceDefinitions.set_top_level_service_params(service_hash,service_hash[:parent_engine])
      clear_error
     return log_error_mesg('Failed to create persistant service ',service_hash) unless add_to_managed_service(service_hash)
     return log_error_mesg('Failed to add service to managed service registry',service_hash) unless test_registry_result(@system_registry.add_to_services_registry(service_hash))
      return true 
      rescue StandardError => e
        log_exception(e)
    end
    
    def force_register_attached_service(service_query)
      complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
      service_hash = @system_registry.find_engine_service_hash(complete_service_query)
      return log_error_mesg( 'force_reregister no matching service found',service_query) unless service_hash.is_a?(Hash)
      add_to_managed_service(service_hash)     
      rescue StandardError => e
        log_exception(e)
     end
     
   def force_deregister_attached_service(service_query)
     complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
     service_hash = @system_registry.find_engine_service_hash(complete_service_query)
    return log_error_mesg( 'force_deregister_ no matching service found',service_query) unless service_hash.is_a?(Hash)
    return remove_from_managed_service(service_hash)   
   end
   
   def force_reregister_attached_service(service_query)
     complete_service_query = ServiceDefinitions.set_top_level_service_params(service_query,service_query[:parent_engine])
     service_hash = @system_registry.find_engine_service_hash(complete_service_query)
     return log_error_mesg( 'force_register no matching service found',service_query) unless service_hash.is_a?(Hash)
     return add_to_managed_service(service_hash) if remove_from_managed_service(service_hash) 
    return false   
     rescue StandardError => e
       log_exception(e)
   end
   
    def deregister_non_persistant_service(service_hash)
      clear_error
     return log_error_mesg('Failed to create persistant service ',service_hash) unless remove_from_managed_service(service_hash)
      return log_error_mesg('Failed to deregsiter service from managed service registry',service_hash) unless test_registry_result(@system_registry.remove_from_services_registry(service_hash))
      return true   
      rescue StandardError => e
        log_exception(e)
    end
    
  #service manager get non persistant services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistant_services(engine)
    clear_error
    params = {}
    params[:parent_engine] = engine.container_name
    params[:container_type] = engine.ctype
    services = get_engine_nonpersistant_services(params)
    p :register_non_persistant_services
    p services.to_s
    services.each do |service_hash|
      register_non_persistant_service(service_hash)
    end
    return true   
    rescue StandardError => e
      log_exception(e)
  end

  #service manager get non persistant services for engine_name
   #for each servie_hash load_service_container and remove hash
   #remove from service registry even if container is down
   def deregister_non_persistant_services(engine)
     clear_error
     params = {}
     params[:parent_engine] = engine.container_name
     params[:container_type] = engine.ctype
     services = get_engine_nonpersistant_services(params)
     p :deregister_non_persistant_services
        p services.to_s
     services.each do |service_hash|
       test_registry_result(@system_registry.remove_from_services_registry(service_hash))
       remove_from_managed_service(service_hash)
     end
     return true   
     rescue StandardError => e
       log_exception(e)
   end

  #@return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    clear_error
    test_registry_result(@system_registry.get_registered_against_service(params))   
    rescue StandardError => e
      log_exception(e)
  end

 
  #def remove_service service_hash
  #  clear_error
  #   if test_registry_result(@system_registry.remove_from_services_registry(service_hash)) == false
  #     log_error_mesg('failed to remove from service registry',service_hash)
  #     return false
  #   end
  #   SystemUtils.debug_output(  :remove_service, service_hash)
  #   return true
  #
  # rescue Exception=>e
  #   if service_hash != nil
  #     p service_hash
  #   end
  #   log_exception(e)
  #   return false
  # end

  #@ removes underly service and remove entry from orphaned services
  #@returns boolean indicating success
  def remove_orphaned_service(service_query_hash)
    clear_error
    service_hash = retrieve_orphan(service_query_hash)
    return log_error_mesg('failed to retrieve orphan service:' +  @last_error.to_s,service_hash)  if service_hash.nil? || service_hash == false
    return test_registry_result(@system_registry.release_orphan(service_hash))   
    rescue StandardError => e
      log_exception(e)
  end




  #@return [Array] of service hash for ObjectName matching the name  identifier
  #@objectName [String]
  #@identifier [String]
  def list_attached_services_for(objectName,identifier)
    clear_error
    SystemUtils.debug_output('services_on_objects_',objectName)
    SystemUtils.debug_output('services_on_objects_',identifier)
    params = {}
    case objectName
    when 'ManagedEngine'
      # FIXME: get from Object
      params[:parent_engine] = identifier
      params[:container_type] = 'container'
      
        
      SystemUtils.debug_output(  :get_engine_service_hashes,'ManagedEngine')
      #      hashes = @system_registry.find_engine_services_hashes(params)
      #      SystemUtils.debug_output('hashes',hashes)

      return test_registry_result(@system_registry.find_engine_services_hashes(params))
      #    attached_managed_engine_services(identifier)
    when 'Volume'
      SystemUtils.debug_output(  :looking_for_volume,identifier)
      return attached_volume_services(identifier)
    when 'Database'
      SystemUtils.debug_output(  :looking_for_database,identifier)
      return attached_database_services(identifier)
    end
    p :no_object_name_match
    p objectName
    return nil
  rescue Exception=>e
    puts e.message
    log_exception(e)
    return params
  end



  
  
  def update_service_configuration(config_hash)
    #load service definition and from configurators definition and if saveable save
    service_definition = software_service_definition(config_hash)
    return log_error_mesg('Missing Service definition file ', config_hash.to_s)  unless service_definition.is_a?(Hash)
    return log_error_mesg('Missing Configurators in service definition', config_hash.to_s) unless service_definition.key?(:configurators)
    configurators = service_definition[:configurators]
    return log_error_mesg('Missing Configurator ', config_hash[:configurator_name]) unless configurators.key?(config_hash[:configurator_name].to_sym)
    configurator_definition = configurators[config_hash[:configurator_name].to_sym]
    unless configurator_definition.key?(:no_save) && configurator_definition[:no_save]
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
    test_registry_result(@system_registry.service_is_registered?(service_hash))  
    rescue StandardError => e
      log_exception(e)
  end

  def all_engines_registered_to(service_type)
   test_registry_result(@system_registry.all_engines_registered_to(service_type))  
        rescue StandardError => e
          log_exception(e)
  end
  
#@returns [Hash] suitable for use  to attach as a service
  #nothing written to the tree
  def reparent_orphan(params)
    test_registry_result(@system_registry.reparent_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end
 
  
def match_orphan_service(service_hash)
  res =  retrieve_orphan(service_hash)
  return true if res.is_a?(Hash)
  return false
end

  def retrieve_orphan(params)
    test_registry_result(@system_registry.retrieve_orphan(params))   
    rescue StandardError => e
      log_exception(e)
  end

def remove_engine_from_managed_engines_registry(params)
  r = @system_registry.remove_from_managed_engines_registry(params)
  return r   
  rescue StandardError => e
    log_exception(e)
end


def orphanate_service(params)
   test_registry_result(@system_registry.orphanate_service(params))   
  rescue StandardError => e
    log_exception(e)
 end

def release_orphan(params)
  test_registry_result(@system_registry.release_orphan(params))   
  rescue StandardError => e
    log_exception(e)
end


# @return [Hash] of [SoftwareServiceDefinition] that Matches @params with keys :type_path :publisher_namespace
def software_service_definition(params)
  clear_error
  SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace] )
rescue Exception=>e
  p :error
  p params
  log_exception(e)
  return nil
end

#test the result and carry last_error from @system_registry if result nil
  #@return result
  def test_registry_result(result)
    clear_error
    log_error_mesg(@system_registry.last_error, result) if result.is_a?(FalseClass)
    return result   
    rescue StandardError => e
      log_exception(e)
  end

  #test the result and carry last_error from @system_registry if nil
  #freeze result object if not nil
  #@return result
  def test_and_lock_registry_result(result)
    if test_registry_result(result)
      result.freeze
    end
    return result
  end   
end
