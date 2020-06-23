@route += '/' + ARGV[3] + '/'

cmd = nil
STDERR.puts("Route #{@route}")
case ARGV[4]
when 'register'
  cmd = ARGV[4]
when 'deregister'
 cmd = ARGV[4]
when 'reregister'
 cmd = ARGV[4]
when 'export'
 cmd = ARGV[4]
when 'import'
@route += '/' + ARGV[4]
content_type='application/octet-stream'
 stream_put(@route, STDIN)
#params = []
#  params[:data] = read_stdin_data
#  perform_post(params)
when 'imports'
 @route += '/import'
STDERR.puts("Route #{@route}")
content_type='application/octet-stream'
 stream_put(@route, STDIN)
 exit
when 'replace'
@route += '/' + ARGV[4]
params = []
  params[:data] = read_stdin_data
  perform_post(params)
end

if cmd.nil?
  n = 4
else
  n = 5
end

len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

@route += '/' + cmd unless cmd.nil?


perform_get