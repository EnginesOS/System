@route += '/' + ARGV[1]
case ARGV[1]
when 'service_manager'
  require 'service_manager.rb'
end