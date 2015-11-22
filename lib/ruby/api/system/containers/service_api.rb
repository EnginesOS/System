class ServiceApi < ContainerApi

  require_relative 'service_api/service_api_image_actions.rb'
  include ServiceApiImageActions
  require_relative 'service_api/service_api_configurations.rb'
  include ServiceApiConfigurations

  require_relative 'service_api/service_api_consumers.rb'
  include ServiceApiConsumers

  require_relative 'service_api/service_api_status_flags.rb'
  include ServiceApiStatusFlags

  require_relative 'service_api/services_api_system.rb'
  include ServiceApiSystem
  
end
