 
@route += '/' + ARGV[0] + '/' + ARGV[1] + '/' + ARGV[2] 
@route += '/' + ARGV[3] if ARGV.count > 2
@route += '/' + ARGV[4] if ARGV.count > 3
@route += '/' + ARGV[5] if ARGV.count > 4
STDERR.puts("\nRoute " + @route.to_s)
perform_get
get_stream(@route)