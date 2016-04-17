@route += '/' + ARGV[0]
case ARGV[0]
when 'containers'
  require_relative 'containers/commands.rb'
when 'engines'
  require_relative 'containers/engines/commands.rb'
when 'services'
  require_relative 'containers/services/commands.rb'
when 'registry'
  require_relative 'registry/commands.rb'
when 'engines_builder'
  require_relative 'engines_builder/commands.rb'
when 'service_manager'
  require_relative 'service_manager/commands.rb'
when 'system'
  require_relative 'system/commands.rb'

end