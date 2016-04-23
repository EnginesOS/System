require '/opt/engines/lib/ruby/system/system_config.rb'
require '/opt/engines/lib/ruby/system/system_utils.rb'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'

#require '/opt/engines/lib/ruby/api/public/engines_osapi_result.rb'
require '/opt/engines/lib/ruby/containers/container.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
require '/opt/engines/lib/ruby/containers/managed_engine.rb'
require '/opt/engines/lib/ruby/containers/managed_service.rb'
require '/opt/engines/lib/ruby/managed_services/service_definitions/software_service_definition.rb'
require '/opt/engines/lib/ruby/service_manager/service_definitions.rb'

class EnginesCore < ErrorsApi
  require '/opt/engines/lib/ruby/containers/system_service.rb'

  # require_relative '../dns_api.rb'

  require_relative '../configurations_api.rb'
  require_relative '../blueprint_api.rb'
  require_relative '../system_preferences.rb'

  require_relative '../memory_statistics.rb'

  require_relative 'container_config_loader.rb'
  include ContainerConfigLoader
  
  require_relative 'core_service_import_export.rb'  
  include CoreServiceImportExport
  
  require_relative 'container_states.rb'
  include ContainerStates
  
  require_relative 'available_services.rb'
  include AvailableServices

  require_relative 'service_configurations.rb'
  include ServiceConfigurations

  require_relative 'service_hash_checks.rb'
  include ServiceHashChecks

  require_relative 'engine_operations.rb'
  include EnginesOperations

  require_relative 'engine_service_operations.rb'
  include EngineServiceOperations

  require_relative 'container_operations.rb'
  include ContainerOperations

  require_relative 'service_operations.rb'
  include ServiceOperations

  require_relative 'domain_operations.rb'
  include DomainOperations

  require_relative 'subservice_operations.rb'
  include SubserviceOperations

  require_relative 'orphan_operations.rb'
  include OrphanOperations

  require_relative 'system_operations.rb'
  include SystemOperations

  require_relative 'result_checks.rb'
  include ResultChecks

  require_relative 'domain_operations.rb'
  include DomainOperations

  require_relative 'registry_trees.rb'
  include RegistryTrees

  require_relative 'engines_core_preferences.rb'
  include  EnginesCorePreferences

  require_relative 'service_manager_operations.rb'
  include ServiceManagerOperations

  require_relative 'docker_operations.rb'
  include DockerOperations

  require_relative 'registry_operations.rb'
  include RegistryOperations

  require_relative 'template_operations.rb'
  include TemplateOperations

  require_relative 'core_build_controller.rb'  
  include CoreBuildController
  
  require_relative 'actionators.rb'
   include Actionators
   
  require_relative 'engines_core_version.rb'
  include EnginesCoreVersion
  
  require_relative 'certificate_actions.rb'
  include CertificateActions
  
  require_relative '../containers/container_api.rb'
  require_relative '../containers/service_api.rb'
  require_relative '../docker/docker_api.rb'
  require_relative '../engines_system/engines_system.rb'
  require '/opt/engines/lib/ruby/service_manager/service_manager.rb'
  require_relative '../registry_handler.rb'
  
  def initialize
    Signal.trap('HUP', proc { api_shutdown })
    Signal.trap('TERM', proc { api_shutdown })
    @docker_api = DockerApi.new
    @system_api = SystemApi.new(self)  # will change to to docker_api and not self
    @registry_handler = RegistryHandler.new(@system_api)
    @container_api = ContainerApi.new(@docker_api, @system_api, self)
    @service_api = ServiceApi.new(@docker_api, @system_api, self)
    @registry_handler.start
    @service_manager = create_service_manager
  end

  #why readers on these apis
#  attr_reader :container_api, :service_api
  
  attr_reader :system_api, :service_manager, :container_api, :service_api
  

  def api_shutdown
    SystemDebug.debug(SystemDebug.system,  :BEING_SHUTDOWN)

    @registry_handler.api_shutdown
    
  end
  def set_first_run_parameters(params_from_gui)
    require_relative '../first_run_wizard.rb'
     params = params_from_gui.dup
     SystemDebug.debug(SystemDebug.first_run,params)
     first_run = FirstRunWizard.new(params)
     first_run.apply(self)
     @last_error = first_run.last_error unless first_run.sucess
     return first_run.sucess
  end
  
  def reserved_engine_names
    names = list_managed_engines
    names.concat(list_managed_services)
    names.concat(list_system_services)
    names
    rescue StandardError => e
       SystemUtils.log_exception(e)
    failed('Gui', 'reserved_engine_names', 'failed')
    return []
  end 
  
  

  
  def reserved_ports
    ports = []
     ports.push(443)
    ports.push(10443)
    ports.push(80)
    ports.push(22)
    ports.push(808)
    ports
  end
 def  get_disk_statistics
   'belum'
 end
  
  def first_run_required?
    require_relative '../first_run_wizard.rb'
    FirstRunWizard.required?
  end
  
  def software_service_definition(params)
    clear_error
    return false unless check_service_hash(params)
    return SoftwareServiceDefinition.find(params[:type_path],params[:publisher_namespace] )
  rescue StandardError => e
    p :error
    p params
    log_exception(e)
    return nil
  end

  def get_build_report(engine_name)
    @system_api.get_build_report(engine_name)
  end

  def save_build_report(container,build_report)
    test_system_api_result(@system_api.save_build_report(container,build_report))
  end

  def container_memory_stats(engine)
 
  MemoryStatistics.container_memory_stats(engine)
    end
    
  def build_engine(params)
    build_controller = BuildController.new(self)
    @build_thread = Thread.new { build_controller.build_engine(params) }
    return true if @build_thread.alive?
    return log_error(params[:engine_name], 'Build Failed to start')
  end

  def shutdown(reason)
    # FIXME: @registry_handler.api_dissconnect
    @system_api.api_shutdown(reason)
  end
  protected
end
