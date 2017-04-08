require '/opt/engines/lib/ruby/system/system_config.rb'
require '/opt/engines/lib/ruby/system/system_utils.rb'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'
require '/opt/engines/lib/ruby/containers/container.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
require '/opt/engines/lib/ruby/containers/managed_engine.rb'
require '/opt/engines/lib/ruby/containers/managed_service.rb'
require '/opt/engines/lib/ruby/containers/system_service/system_service.rb'
require '/opt/engines/lib/ruby/containers/managed_utility/managed_utility.rb'
require '/opt/engines/lib/ruby/managed_services/service_definitions/software_service_definition.rb'
#require '/opt/engines/lib/ruby/system/deal_with_json.rb'
require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'

class EnginesCore < ErrorsApi

  #  require_relative 'errors/engines_core_errors.rb'
  #  include EnginesCoreErrors

  require_relative '../configurations_api.rb'
  require_relative '../blueprint_api.rb'
  require_relative '../system_preferences.rb'

  require_relative '../memory_statistics.rb'
  require_relative 'service_hash_checks.rb'
  include ServiceHashChecks

  require_relative 'system/container_config_loader.rb'
  include ContainerConfigLoader
  require_relative 'system/system_operations.rb'
  include SystemOperations
  require_relative 'system/engines_core_system.rb'
  include EnginesCoreSystem
  require_relative 'system/certificate_actions.rb'
  include CertificateActions

  require_relative 'containers/core_service_import_export.rb'
  include CoreServiceImportExport
  require_relative 'containers/container_states.rb'
  include ContainerStates
  require_relative 'containers/actionators.rb'
  include Actionators
  require_relative 'containers/engine_operations.rb'
  include EnginesOperations
  require_relative 'containers/container_operations.rb'
  include ContainerOperations
  require_relative 'containers/docker_operations.rb'
  include DockerOperations

  require_relative 'service_management/available_services.rb'
  include AvailableServices
  require_relative 'service_management/service_configurations.rb'
  include ServiceConfigurations
  require_relative 'service_management/engine_service_operations.rb'
  include EngineServiceOperations
  require_relative 'service_management/service_operations.rb'
  include ServiceOperations
  require_relative 'service_management/domain_operations.rb'
  include DomainOperations
  require_relative 'service_management/subservice_operations.rb'
  include SubserviceOperations
  require_relative 'service_management/orphan_operations.rb'
  include OrphanOperations
  require_relative 'service_management/domain_operations.rb'
  include DomainOperations
  require_relative 'service_management/registry_trees.rb'
  include RegistryTrees
  require_relative 'service_management/service_manager_operations.rb'
  include ServiceManagerOperations

  require_relative 'engines_core_preferences.rb'
  include  EnginesCorePreferences

  require_relative 'registry_container_operations.rb'
  include RegistryContainerOperations

  require_relative 'template_operations.rb'
  include TemplateOperations

  require_relative 'core_build_controller.rb'
  include CoreBuildController

  require_relative 'engines_core_version.rb'
  include EnginesCoreVersion
  def command_is_system_service?
    return true if $PROGRAM_NAME.end_with?('system_service.rb')
  end

  unless command_is_system_service?
    require_relative 'user_auth.rb'
    include UserAuth
  end

  require_relative '../containers/container_api/container_api.rb'
  require_relative '../containers/service_api/service_api.rb'
  require_relative '../docker/docker_api.rb'
  require_relative '../engines_system/engines_system.rb'
  require '/opt/engines/lib/ruby/service_manager/service_manager.rb'
  require_relative '../registry_handler.rb'
  require_relative 'errors/engines_core_error.rb'

  def initialize
    Signal.trap('HUP', proc { dump_stats })  #api_shutdown })
    Signal.trap('TERM', proc { api_shutdown })
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  # will change to to docker_api and not self
    @registry_handler = RegistryHandler.new(@system_api)
    @container_api = ContainerApi.new(@docker_api, @system_api, self)
    @service_api = ServiceApi.new(@docker_api, @system_api, self)
    @service_manager = ServiceManager.new(self) # create_service_manager
  end

  attr_reader :system_api, :container_api, :service_api

  protected
end
