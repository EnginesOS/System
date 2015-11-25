require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'

require '/opt/engines/lib/ruby/system/system_utils.rb'

class ServiceManager  < ErrorsApi
  
  require_relative 'result_checks.rb'
  require_relative 'sm_service_definitions.rb'
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
  require_relative 'registry_client.rb'
  
#  attr_accessor :system_registry_client
  #@ call initialise Service Registry Tree which conects to the registry server
  def initialize(core_api)
    @core_api = core_api
    @system_registry = SystemRegistryClient.new(@core_api)
  end
  

 
  include SMSubservices
  include SmServiceInfo
  include SmServiceForcedMethods
  include SmServiceDefinitions
  include SmRegistryTree
  include SmOrphanServices
  include SmEngineServices
  include SMAttachedServices
  include SmAttachStaticServices
  include RegistryClient
  include SmServiceControl
  include SmServiceConfigurations



end
