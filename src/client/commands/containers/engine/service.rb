@route += '/' + ARGV[3] + '/'
params = {}
STDERR.puts  @route 
cmd = nil
post = false
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
cmd = ARGV[4]
post = true
STDERR.puts  @route 
params[:data] = read_stdin_data  
when 'replace'
@route += '/' + ARGV[4]
  params[:data] = read_stdin_data
  perform_post(params,'application/octet-stream')
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

if post == true
  STDERR.puts  @route 
  perform_post(params,'application/octet-stream')
else 
perform_get
end