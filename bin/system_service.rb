#!/usr/bin/ruby

require '/opt/engines/lib/ruby/api/system/engines_system/engines_system'
require 'thread'
require 'yaml'

require '/opt/engines/lib/ruby/system/engines_error'
require '/opt/engines/lib/ruby/api/system/errors_api'

system_api = SystemApi.instance

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
  t = service.start_container
  t.join
when 'create_only'
  t = service.create_container
  t.join
when 'create'
  t = service.create_container
  t.join
  service.wait_for('create', 120)
  t = service.start_container
  t.join
when 'recreate'
  t = service.destroy_container
  t.join
  t = service.create_container
  t.join
when 'stop'
  t = service.stop_container
  t.join
when 'destroy'
  t = service.destroy_container
  t.join
when 'state'
  t = service.read_state
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
