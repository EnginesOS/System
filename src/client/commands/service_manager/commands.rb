@route += '/' + ARGV[0]
case ARGV[1]
when 'service_definition'
  require_relative 'service_definition.rb'
when 'service_definitions'
  require_relative 'service_definitions.rb'
when 'orphans'
  require_relative 'orphan_services.rb'
when 'orphan'
  require_relative 'orphan_service.rb'
when 'available_services'
  require_relative 'available_services.rb'
when 'persistent_services'
  require_relative 'persistent_services.rb'
when 'persistent_service'
  require_relative 'persistent_service.rb'
end