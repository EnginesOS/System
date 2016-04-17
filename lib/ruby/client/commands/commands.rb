@route += '/' + ARGV[0]
case ARGV[0]
when 'containers'
  require_relative 'commands/containers/commands.rb'
when 'engines'
  require_relative 'commands/containers/engines/commands.rb'
when 'services'
  require_relative 'commands/containers/services/commands.rb'
when 'registry'
  require_relative 'commands/registry/commands.rb'
when 'engines_builder'
  require_relative 'commands/engines_builder/commands.rb'
when 'service_manager'
  require_relative 'commands/service_manager/commands.rb'
when 'system'
  require_relative 'commands/system/commands.rb'

end