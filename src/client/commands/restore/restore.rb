 
@route += '/' + ARGV[0] + '/' + ARGV[1] + '/' + ARGV[2] + '/' + ARGV[3]

content_type='application/octet-stream'
STDERR.puts  @route
stream_put(STDIN)
#params = {data: read_stdin_data}
#perform_put(params, content_type)