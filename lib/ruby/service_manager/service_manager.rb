require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'

require '/opt/engines/lib/ruby/system/system_utils.rb'

class ServiceManager  < ErrorsApi
  require_relative 'sm_service_control.rb'
  require_relative 'sm_engine_services.rb'
  require_relative 'sm_service_forced_methods.rb'
  require_relative 'sm_registry_tree.rb'
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
  include SmRegistryTree
  include SmOrphanServices
  include SmEngineServices
  include SMAttachedServices
  include SmAttachStaticServices
  include SmServiceControl
  include SmServiceConfigurations
  include SharedServices
  include SmPublicKeyAccess

  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'

  private
  def system_registry_client
    @system_registry ||= SystemRegistryClient.new(@core_api)
  end

end
