@route += '/' + ARGV[2]
case ARGV[2]
when 'base_os'
  require_relative 'base_os.rb'
when 'registry'
  require_relative 'registry.rb'
when 'engines_system'
  require_relative 'engines_system.rb'
end
