require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'
require_relative 'service_definitions.rb'
require_relative 'result_checks.rb'
require_relative 'non_persistant_services.rb'
require_relative 'engine_service_readers.rb'
require_relative 'service_readers.rb'
require '/opt/engines/lib/ruby/system/system_utils.rb'
class ServiceManager  < ErrorsApi

  require_relative 'service_container_actions.rb'
  require_relative 'registry_tree.rb'
  require_relative 'orphan_services.rb'
#  include ServiceDefinitions
  include RegistryTree
  include OrphanServices
  include NonPersistantServices
  include EngineServiceReaders
  include ServiceReaders
  
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
    service_definition = ServiceDefinitions.software_service_definition(config_hash)
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
  




def remove_engine_from_managed_engines_registry(params)
  r = @system_registry.remove_from_managed_engines_registry(params)
  return r   
  rescue StandardError => e
    log_exception(e)
end


end
