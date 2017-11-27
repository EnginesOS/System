 
@route += '/' + ARGV[0] + '/' + ARGV[1] + '/' + '/' + ARGV[2]

content_type='application/octet-stream'
STDERR.puts  @route
params = {data: read_stdin_data}


perform_post(params, content_type)