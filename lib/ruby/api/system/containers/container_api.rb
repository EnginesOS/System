class ContainerApi < ErrorsApi
  require_relative '../container_state_files.rb'
  require_relative 'service_hash_builders.rb'

  require_relative 'container_api/api_result_checks.rb'
  include ApiResultChecks

  require_relative 'container_api/container_docker_actions.rb'
  include ContainerDockerActions

  require_relative 'container_api/engine_blueprint.rb'
  include EngineBlueprint

  require_relative 'container_api/engine_dependancies.rb'
  include EngineDependancies

  require_relative 'container_api/engine_service_registration.rb'
  include EngineServiceRegistration

  require_relative 'container_api/engine_status_flags.rb'
  include EngineStatusFlags

  require_relative 'container_api/engine_image_actions.rb'
  include EngineImageActions

  require_relative 'container_api/engines_system.rb'
  include EnginesSystem
  def initialize(docker_api, system_api, engines_core)
    @docker_api = docker_api
    @system_api = system_api
    @engines_core = engines_core
  end

end
