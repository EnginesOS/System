
case ARGV[1]
when 'control'
  require_relative 'control/commands.rb'
  
when 'keys'
require_relative 'keys/commands.rb'

when 'certs'
require_relative 'certs.rb'

when 'config'
  require_relative 'config.rb'
  
when 'domains'
  require_relative 'domains.rb'
  
when 'first_run' 
  require_relative 'first_run.rb'
  
when 'metrics'
  require_relative 'metrics.rb'
  
when 'reserved'
  require_relative 'reserved.rb'
  
when 'status'
require_relative 'status.rb'

when 'template'
require_relative 'template.rb'

when 'version'
  require_relative 'version.rb'
end

