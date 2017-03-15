require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'

require '/opt/engines/lib/ruby/system/system_utils.rb'

class ServiceManager  < ErrorsApi

  require_relative 'service_definitions.rb'
  require_relative 'sm_service_control.rb'
  require_relative 'sm_engine_services.rb'
  require_relative 'sm_service_forced_methods.rb'
 # require_relative 'sm_registry_tree.rb'
  require_relative 'sm_orphan_services.rb'
  require_relative 'sm_subservices.rb'
  require_relative 'sm_service_info.rb'
  require_relative 'sm_attach_static_services.rb'
  require_relative 'sm_attached_services.rb'
  require_relative 'sm_service_info.rb'
  require_relative 'sm_service_configurations.rb'

  require_relative 'shared_services.rb'
  require_relative 'errors/engines_service_manager_errors.rb'
  require_relative 'sm_public_key_access.rb'
  def initialize(core_api)
    @core_api = core_api    
  end

  include EnginesServiceManagerErrors
  include SMSubservices
  include SmServiceInfo
  include SmServiceForcedMethods
  #include SmRegistryTree
  include SmOrphanServices
  include SmEngineServices
  include SMAttachedServices
  include SmAttachStaticServices

  include SmServiceControl
  include SmServiceConfigurations
  include SharedServices
  include SmPublicKeyAccess

  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  
  private 
  def system_registry_client
     @system_registry ||= SystemRegistryClient.new(@core_api)
   end

  # WTF why not  SoftwareServiceDefinition.set_top_level_service_params(service_hash, container_name)
  def set_top_level_service_params(service_hash, container_name)
    container_name = service_hash[:parent_engine] if service_hash.key?(:parent_engine)
    container_name = service_hash[:engine_name] if container_name == nil
    return SystemUtils.log_error_mesg('no set_top_level_service_params_nil_service_hash container_name:',container_name) if container_name.nil?
    return SystemUtils.log_error_mesg('no set_top_level_service_params_nil_container_name service_hash:',service_hash)  if service_hash.nil?
    service_def = SoftwareServiceDefinition.find(service_hash[:type_path],service_hash[:publisher_namespace])
    return service_def if service_def.is_a?(EnginesError)
    service_hash[:service_container_name] = service_def[:service_container]
    service_hash[:persistent] = service_def[:persistent]
    service_hash[:parent_engine] = container_name
    service_hash[:container_type] = 'container' if service_hash.has_key?(:container_type) == false || service_hash[:container_type] ==nil
    service_hash[:variables] = {} unless service_hash.has_key?(:variables)
    service_hash[:variables][:parent_engine] = container_name
    if service_def.key?(:priority)
      service_hash[:priority] = service_def[:priority]
    else
      service_hash[:priority] = 0
    end
    return service_hash if service_hash.key?(:service_handle) && ! service_hash[:service_handle].nil?

    if service_def.key?(:service_handle_field) && !service_def[:service_handle_field].nil?
      handle_field_sym = service_def[:service_handle_field].to_sym
      return SystemUtils.log_error_mesg('Missing Service Handle field in variables',handle_field_sym) unless service_hash[:variables].key?(handle_field_sym)
      service_hash[:service_handle] = service_hash[:variables][handle_field_sym]
    else
      service_hash[:service_handle] = container_name
    end

    service_hash
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

end
