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
  service.wait_for('stop', 120)
  service.wait_for('start', 120)
when 'start'
  service.start_container
  service.wait_for('start', 120)
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
  service.stop_container
  service.wait_for('stop', 120)
when 'destroy'
  service.destroy_container
  service.wait_for('nocontainer', 120)
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
  service.wait_for(ARGV[2],ARGV[3].to_i)
  STDOUT.puts  "#{service.read_state}"
when 'wait_for_startup'
  service.wait_for_startup(ARGV[2].to_i)
  STDOUT.puts  "#{service.read_state}"
end
