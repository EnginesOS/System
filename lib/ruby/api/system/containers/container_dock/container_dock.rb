require_relative '../../engines_system/engines_system'
require_relative '../../engines_core/engines_core'
require '/opt/engines/lib/ruby/event_handling/event_handler'

class ContainerDock < ErrorsApi
  class << self
    def instance
      @@container_instance ||= self.new
    end
  end

  require_relative '../service_hash_builders.rb'
  require '/opt/engines/lib/ruby/system/deal_with_json.rb'

  require_relative 'engine_api_errors.rb'
  include EngineApiErrors

  require_relative 'container_dock_events.rb'
  include ContainerDockEvents

  require_relative 'engines_api_system.rb'
  include EnginesApiSystem

  require_relative 'container_dock_docker_actions.rb'
  include ContainerDockDockerActions

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

  require_relative 'container_dock_locale.rb'
  include ContainerDockLocale

  require_relative 'api_actionators.rb'
  include ApiActionators

  require_relative 'engine_api_export_import.rb'
  include EngineApiExportImport

  require_relative  'container_dock_schedules.rb'
  include ContainerDockSchedules

  require_relative 'volume_builder.rb'
  include ContainerDockVolumeBuilder

  require_relative 'container_dock_services.rb'
  include ContainerDockServices

  protected

  def event_handler
     @event_handler ||= EventHandler.instance
  end

  def system_api
    @system_api ||= SystemApi.instance
  end

  def docker_api
    @docker_api ||= DockerApi.instance
  end

  def core
    @core ||= EnginesCore.instance
  end
end
