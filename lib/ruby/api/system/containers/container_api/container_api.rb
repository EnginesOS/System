class ContainerApi < ErrorsApi
  require_relative '../../container_state_files.rb'
  require_relative '../service_hash_builders.rb'

  require_relative 'container_api/engine_api_errors.rb'
  include EngineApiErrors
  
  require_relative 'container_api/api_result_checks.rb'
  include ApiResultChecks

  require_relative 'container_api/container_api_docker_actions.rb'
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

  require_relative 'engines_api_system.rb'
  include EnginesApiSystem
  
  require_relative 'core_api_access.rb'
  include CoreApiAccess
  
  require_relative 'api_actionators.rb'
  include ApiActionators
  
  require_relative 'engine_api_export_import.rb'
  include EngineApiExportImport
  
  def initialize(_docker_api, _system_api, _engines_core)
    @docker_api = _docker_api
    @system_api = _system_api
    @engines_core =  _engines_core
  end

end
