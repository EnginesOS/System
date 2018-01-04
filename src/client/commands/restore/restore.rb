@route += '/' + ARGV[0] + '/' + ARGV[1] + '/' + ARGV[2] + '/' + ARGV[3]

content_type='application/octet-stream'
STDERR.puts  @route
if ARGV.length == 5
  f = File.new(ARGV[4],'r')
  stream_put(f)
else
  stream_put(STDIN)
end
#params = {data: read_stdin_data}
#perform_put(params, content_type)