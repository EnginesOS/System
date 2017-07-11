class ServiceApi < ContainerApi
  # Fixme and move timeouts to a static conf

  require_relative 'service_api_image_actions.rb'
  include ServiceApiImageActions
  require_relative 'service_api_configurations.rb'
  include ServiceApiConfigurations

  require_relative 'service_api_consumers.rb'
  include ServiceApiConsumers

  require_relative 'service_api_status_flags.rb'
  include ServiceApiStatusFlags

  require_relative 'service_api_system.rb'
  include ServiceApiSystem

  require_relative 'service_api_readers.rb'
  include ServiceApiReaders

  require_relative 'service_api_load_services.rb'
  include ServiceApiLoadServices

  require_relative 'service_api_docker_actions.rb'
  include ServiceApiDockerActions
  
  require_relative 'service_api_restore.rb'
  include ServiceApiRestore
end
