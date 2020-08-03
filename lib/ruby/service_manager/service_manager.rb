class ServiceManager  < ErrorsApi
  class << self
    def instance
      @@instance ||= self.new
    end
  end
  require 'rubytree'
  require_relative '../templater/templater.rb'
  require_relative '../system/system_access.rb'
  require '/opt/engines/lib/ruby/system/system_utils.rb'
  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'
  
  require_relative 'managed_services/sm_service_control.rb'
  #include SmServiceControl
  require_relative 'managed_services/sm_engine_services.rb'
  #include SmEngineServices
  require_relative 'managed_services/sm_service_forced_methods.rb'
  #include SmServiceForcedMethods
  require_relative 'sm_registry_tree.rb'
  #include SmRegistryTree
  require_relative 'managed_services/sm_orphan_services.rb'
  #include SmOrphanServices
  require_relative 'managed_services/sm_subservices.rb'
  #include SMSubservices
  require_relative 'managed_services/sm_service_info.rb'
  #include SmServiceInfo
  require_relative 'managed_services/sm_attach_static_services.rb'
  #include SmAttachStaticServices
  require_relative 'managed_services/sm_attached_services.rb'
  #include SMAttachedServices
  require_relative 'managed_services/sm_service_info.rb'
  #include SmServiceInfo
  require_relative 'managed_services/sm_service_configurations.rb'
  #include SmServiceConfigurations
  require_relative 'managed_services/shared_services.rb'
  #include SharedServices
  require_relative 'managed_services/sm_engine_cron_service.rb'
  #include SmEngineCronService
  require_relative 'fixes/filesystem_contid.rb'
  #include FileSystemContid
  require_relative 'errors/engines_service_manager_errors.rb'
  #include EnginesServiceManagerErrors
  require_relative 'managed_services/sm_list_services.rb'
  #include SMListServices

  def api_shutdown
    system_registry_client.api_shutdown
  end
  
  protected
  
  require_relative 'system_registry/system_registry_client.rb'
  
  def system_registry_client
    @system_registry_client ||= SystemRegistryClient.instance
  end

  def core
    @core ||= EnginesCore.instance
  end

end
