#!/home/engines/.rbenv/shims/ruby

require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'

require "/opt/engines/lib/ruby/containers/system_service.rb"

core_api = EnginesCore.new  

system_api = core_api.system_api

service = system_api.loadSystemService(ARGV[0])

case ARGV[1]
when 'start'
  p service.start_container
when 'create'
  p service.create_container
when 'stop'
  p service.stop_container
when 'destroy'
  p service.destroy_container
    
end