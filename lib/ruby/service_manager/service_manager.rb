require 'rubytree'

#require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'

require '/opt/engines/lib/ruby/system/system_utils.rb'

class ServiceManager  < ErrorsApi
  require_relative 'managed_services/sm_service_control.rb'
  require_relative 'managed_services/sm_engine_services.rb'
  require_relative 'managed_services/sm_service_forced_methods.rb'
  require_relative 'sm_registry_tree.rb'
  require_relative 'managed_services/sm_orphan_services.rb'
  require_relative 'managed_services/sm_subservices.rb'
  require_relative 'managed_services/sm_service_info.rb'
  require_relative 'managed_services/sm_attach_static_services.rb'
  require_relative 'managed_services/sm_attached_services.rb'
  require_relative 'managed_services/sm_service_info.rb'
  require_relative 'managed_services/sm_service_configurations.rb'
  require_relative 'managed_services/shared_services.rb'
  require_relative 'errors/engines_service_manager_errors.rb'
  require_relative 'managed_services/sm_engine_cron_service.rb'

  require_relative 'fixes/filesystem_contid.rb'
  include FileSystemContid

  require_relative 'managed_services/sm_list_services.rb'
  #  require_relative 'sm_public_key_access.rb'

  include EnginesServiceManagerErrors
  include SMSubservices
  include SmServiceInfo
  include SmServiceForcedMethods
  include SmRegistryTree
  include SmOrphanServices
  include SmEngineServices
  include SMAttachedServices
  include SmAttachStaticServices
  include SmServiceControl
  include SmServiceConfigurations
  include SharedServices
  include SmEngineCronService
  include SMListServices
  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'
  
  def api_shutdown
    @system_registry.api_shutdown
  end
  
  protected
  
  require_relative 'system_registry/system_registry_client.rb'
  
  def system_registry_client
    @system_registry ||= SystemRegistryClient.instance
  end

  def core
    @core ||= EnginesCore.instance
  end

end
