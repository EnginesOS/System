@route += '/' + ARGV[3] + '/'  #{non_}persistent
params = {}
#STDERR.puts 'engine service ns tp sh ' +  @route
cmd = nil
post = false
del = false
content_type='application/octet-stream'
n = 5
case ARGV[4]
when 'register'
  cmd = ARGV[4]
when 'deregister'
  cmd = ARGV[4]
when 'reregister'
  cmd = ARGV[4]
when 'export'
@wait_for=5000
  cmd = ARGV[4]
when 'import'
@wait_for=5000
  cmd ='overwrite'
  post = :stream
  STDERR.puts  @route

when 'import_file'
  @wait_for=5000
  cmd = 'overwrite'
  post = :file
  file =  ARGV[5]
  n = 6
when 'replace_file'
@wait_for=5000
  cmd = 'replace'
  post = :file
  file =  ARGV[5]
  n = 6

when 'replace'
@wait_for=5000
  cmd = ARGV[4]
  post = :stream
  STDERR.puts  @route


when 'update'
@wait_for=5000
  cmd = ARGV[4]
  cmd = nil
  post = true
  content_type='application/json_parser'
  STDERR.puts  @route
  params = read_stdin_json
end

n = 4 if cmd.nil?

len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

@route += '/' + cmd unless cmd.nil?

if post == true
  STDERR.puts  'Posting'  + @route
  perform_post(params, content_type)
elsif post == :file
  io_f = File.open(file, 'r')
  STDERR.puts  'stream_file'  + @route
  stream_file(@route , io_f)
elsif post == :stream
  STDERR.puts  'stream_io'  + @route
  stream_io(@route , STDIN)
elsif del == true
  then
  perform_del
else
  perform_get
end