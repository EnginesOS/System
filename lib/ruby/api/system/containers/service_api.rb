class ServiceApi < ContainerApi

  require_relative 'service_api/service_image_actions.rb'
  include ServiceImageActions
  require_relative 'service_api/service_configurations.rb'
  include ServiceConfigurations

  require_relative 'service_api/service_consumers.rb'
  include ServiceConsumers

  require_relative 'service_api/service_status_flags.rb'
  include ServiceStatusFlags

  require_relative 'service_api/servics_system.rb'
  include ServicesSystem

end
