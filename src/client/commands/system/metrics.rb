command_usage unless ARGV[2].is_a?(String)

case ARGV[2]
#when 'mem'
#when 'load'
when 'mem_stats'
  @route += '/' + 'memory/statistics'
  #when 'disk'
else
  @route += '/' + ARGV[2]
end
@route += '/' + ARGV[3] if ARGV.count > 3
perform_get