#!/usr/bin/ruby
#/home/engines/.rbenv/shims/ruby

require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
require 'thread'
require 'yaml'

#require '/opt/engines/lib/ruby/containers/system_service.rb'
#require '/opt/engines/lib/ruby/containers/container.rb'
#require '/opt/engines/lib/ruby/containers/managed_container.rb'
#require '/opt/engines/lib/ruby/containers/managed_engine.rb'
#require '/opt/engines/lib/ruby/containers/managed_service.rb'
#require '/opt/engines/lib/ruby/managed_services/service_definitions/software_service_definition.rb'
#require '/opt/engines/lib/ruby/managed_services/service_definitions/service_top_level.rb'

core_api = EnginesCore.new  

system_api = core_api.system_api

service = system_api.loadSystemService(ARGV[0])
if service.is_a?(EnginesError)
p service.to_s
exit 127
end 

case ARGV[1]
when 'restart'
  p service.restart_container
when 'start'
  p service.start_container
when 'create'
  p service.create_container
when 'stop'
  p service.stop_container
when 'destroy'
  p service.destroy_container
when 'state'
  p service.read_state
when 'set_state'
  p service.set_state
when 'status'  
  p service.status
when 'mem_stat' 
p MemoryStatistics.container_memory_stats(service)
when 'wait_for'
  p service.wait_for(ARGV[2],ARGV[3].to_i)
when 'wait_for_startup'
  p service.wait_for_startup(ARGV[2].to_i)  
end 

