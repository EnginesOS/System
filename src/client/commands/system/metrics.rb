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

perform_get