class ContainerApi < ErrorsApi
  
 
  require_relative '../service_hash_builders.rb'
  require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  
  require_relative 'engine_api_errors.rb'
  include EngineApiErrors
  
  require_relative 'container_api_events.rb' 
  include ContainerApiEvents
  
  require_relative 'engines_api_system.rb'
  include EnginesApiSystem
  
  require_relative 'container_api_docker_actions.rb'
  include ContainerApiDockerActions

  require_relative 'engine_api_blueprint.rb'
  include EngineApiBlueprint

  require_relative 'engine_api_dependancies.rb'
  include EngineApiDependancies

  require_relative 'engine_api_service_registration.rb'
  include EngineApiServiceRegistration

  require_relative 'engine_api_status_flags.rb'
  include EngineApiStatusFlags

  require_relative 'engine_api_image_actions.rb'
  include EngineApiImageActions

  require_relative 'container_api_locale.rb'
  include ContainerApiLocale
  
  require_relative 'core_api_access.rb'
  include CoreApiAccess
  
  require_relative 'api_actionators.rb'
  include ApiActionators
  
  require_relative 'engine_api_export_import.rb'
  include EngineApiExportImport
  
  require_relative  'container_api_schedules.rb'
  include ContainerApiSchedules

  def initialize(_docker_api, _system_api, _engines_core)
    @docker_api = _docker_api
    @system_api = _system_api
    @engines_core = _engines_core
  end
  
  def system_value_access    
    @engines_core.system_value_access
  end

end
