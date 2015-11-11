require 'rubytree'

require_relative 'system_registry/system_registry_client.rb'
require_relative '../templater/templater.rb'
require_relative '../system/system_access.rb'
require_relative 'service_definitions.rb'


require '/opt/engines/lib/ruby/system/system_utils.rb'

class ServiceManager  < ErrorsApi
  
  require_relative 'result_checks.rb'
  
  require_relative 'non_persistant_services.rb'
  require_relative 'engine_service_readers.rb'
  require_relative 'service_container_actions.rb'
  require_relative 'registry_tree.rb'
  require_relative 'orphan_services.rb'
  require_relative 'subservices.rb'
  require_relative 'service_readers.rb'
  require_relative 'load_container_services.rb'
  require_relative 'attached_services.rb'
  require_relative 'service_writers.rb'
  require_relative 'configurations.rb'

  #@ call initialise Service Registry Tree which conects to the registry server
  def initialize(core_api)
    @core_api = core_api
    @system_registry = SystemRegistryClient.new(@core_api)
  end

  def system_registry_client
 #   @system_registry = SystemRegistryClient.new(@core_api) if @system_registry.nil?
    return @system_registry
  end
  
 
  include Configurations
  include RegistryTree
  include AttachedServices
  include OrphanServices
  include Subservices
  include NonPersistantServices
  include EngineServiceReaders
  include ServiceReaders
  include LoadContainerServices
  include ServiceWriters

end
