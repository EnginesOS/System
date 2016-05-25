@route += '/' + ARGV[0]
case ARGV[1]
when 'service_definitions'
  require_relative 'service_definitions.rb'
when 'orphans'
require_relative 'orphan_services.rb'
end