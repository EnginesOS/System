@route += '/' + ARGV[0] + '/' + ARGV[1]
case ARGV[1]
when 'login'
  require_relative 'login.rb'
when 'loginb'
  require_relative 'login.rb'
when 'control'
  require_relative 'control/commands.rb'
when 'users'
  require_relative 'users.rb'
when 'user'
  require_relative 'user.rb'
when 'keys'
  require_relative 'keys/commands.rb'
when 'key'
  require_relative 'keys/commands.rb'

when 'certs'
  require_relative 'certs.rb'

when 'cert'
  require_relative 'cert.rb'

when 'config'
  require_relative 'config.rb'

when 'domain'
  require_relative 'domain.rb'

when 'domains'
  require_relative 'domains.rb'

when 'do_first_run'
  require_relative 'do_first_run.rb'

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

when 'system_user'
  require_relative 'system_user.rb'

when 'uadmin'
  require_relative 'uadmin.rb'

when 'fixes'
  require_relative 'fixes.rb'
when 'system_services'
  require_relative 'system_services.rb'

when 'system_service'
  require_relative 'system_services.rb'
  
end
perform_get
