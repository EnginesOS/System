class ServiceDock < ContainerDock
  class << self
    def instance
      @@service_instance ||= self.new
    end
  end

  require_relative 'service_dock_image_actions.rb'
  include ServiceDockImageActions
  require_relative 'service_dock_configurations.rb'
  include ServiceDockConfigurations

  require_relative 'service_dock_consumers.rb'
  include ServiceDockConsumers

  require_relative 'service_dock_status_flags.rb'
  include ServiceDockStatusFlags

  require_relative 'service_dock_system.rb'
  include ServiceDockSystem

  require_relative 'service_dock_readers.rb'
  include ServiceDockReaders

  require_relative 'service_dock_load_services.rb'
  include ServiceDockLoadServices

  require_relative 'service_dock_docker_actions.rb'
  include ServiceDockDockerActions
  
  require_relative 'service_dock_restore.rb'
  include ServiceDockRestore
end
