command_usage unless ARGV[2].is_a?(String)

@route += '/' + ARGV[2]
perform_get
#case ARGV[2]
#when 'hostnames'
#when 'ports'
#when 'engine_names'
#end