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
  STDOUT.puts service.restart_container.to_s
when 'start'
  STDOUT.puts service.start_container.to_s
when 'create'
  STDOUT.puts service.create_container.to_s
when 'stop'
  STDOUT.puts service.stop_container.to_s
when 'destroy'
  STDOUT.puts service.destroy_container.to_s
when 'state'
  STDOUT.puts service.read_state.to_s
when 'set_state'
  STDOUT.puts service.set_state.to_s
when 'status'  
  STDOUT.puts service.status.to_s
when 'mem_stat' 
STDOUT.puts MemoryStatistics.container_memory_stats(service).to_s
when 'wait_for'
  STDOUT.puts service.wait_for(ARGV[2],ARGV[3].to_i)
when 'wait_for_startup'
  STDOUT.puts service.wait_for_startup(ARGV[2].to_i)  
end 

