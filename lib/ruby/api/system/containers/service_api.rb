class ServiceApi < ContainerApi
  # Fixme and move timeouts to a static conf
 

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
  
  require_relative 'service_api/services_api_readers.rb'
  include ServiceApiReaders
   
end
