#!/usr/bin/ruby

require '/opt/engines/lib/ruby/api/system/engines_system/engines_system'
require 'thread'
require 'yaml'
require '/opt/engines/lib/ruby/system/engines_error'
require '/opt/engines/lib/ruby/api/system/errors_api'

system_api = SystemApi.instance

service = system_api.loadSystemService(ARGV[0])
if service.is_a?(EnginesError)
  p "#{service}"
  exit 127
end

case ARGV[1]
when 'restart'
 service.restart_container
when 'start'
  STDOUT.puts "#{service.start_container}"
when 'create_only'
  service.create_container
when 'create'
  service.create_container
  service.wait_for('create', 120)
  service.start_container
  service.wait_for('start', 120)
when 'recreate'
  service.destroy_container
  service.wait_for('nocontainer', 120)
  service.create_container
  service.wait_for('start', 120)
when 'stop'
  STDOUT.puts "#{service.stop_container}"
when 'destroy'
  service.destroy_container
when 'state'
  STDOUT.puts "#{service.read_state}"
when 'set_state'
  STDOUT.puts "#{service.set_state}"
when 'status'
  STDOUT.puts "#{service.status}"
when 'status'
  STDOUT.puts "#{service.inspect}"
when 'mem_stat'
  STDOUT.puts MemoryStatistics.container_memory_stats(service).to_s
when 'wait_for'
  STDOUT.puts service.wait_for(ARGV[2],ARGV[3].to_i)
when 'wait_for_startup'
  STDOUT.puts service.wait_for_startup(ARGV[2].to_i)
end
