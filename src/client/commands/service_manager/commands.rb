@route += '/' + ARGV[1]
case ARGV[1]
when 'service_definitions'
  require_relative 'service_definitions.rb'
end