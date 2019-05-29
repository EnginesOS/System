#!/usr/bin/ruby


require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
require 'thread'
require 'yaml'

core_api = EnginesCore.new

system_api = core_api.system_api

service = system_api.loadSystemService(ARGV[0])
if service.is_a?(EnginesError)
  p service.to_s
  exit 127
end

case ARGV[1]
when 'restart'
  t = service.restart_container
  t.join
when 'start'
  t =  service.start_container
  t.join
when 'create'
  t=service.create_container
  t.join
when 'stop'
  t=service.stop_container
  t.join
when 'destroy'
  t=service.destroy_container
  t.join
when 'state'
  t=service.read_state
  t.join
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

