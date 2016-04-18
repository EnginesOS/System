@route += '/' + ARGV[1]

case ARGV[1]
when 'engines'
require_relative 'engines/commands.rb'
when 'services'
require_relative 'services/commands.rb'
when 'changed'
@route += '/'
perform_get

end