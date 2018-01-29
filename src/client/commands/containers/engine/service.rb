@route += '/' + ARGV[3] + '/'  #{non_}persistent
params = {}
#STDERR.puts 'engine service ns tp sh ' +  @route
cmd = nil
post = false
del = false
content_type='application/octet-stream'
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
  post = :stream
  STDERR.puts  @route

when 'import_file'
  cmd = 'import'
  post = :file
  file =  ARGV[5]
  n = 6
when 'replace_file'
  cmd = 'replace'
  post = :file
  file =  ARGV[5]
  n = 6

when 'replace'
  cmd = ARGV[4]
  post = :stream
  STDERR.puts  @route
  params[:data] = read_stdin_data

when 'update'
  cmd = ARGV[4]
  cmd = nil
  post = true
  content_type='application/json_parser'
  STDERR.puts  @route
  params = read_stdin_json
  n = 5

end

if cmd.nil? && n < 5
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
  STDERR.puts  'Posting'  + @route
  perform_post(params, content_type)
elsif post == :file
  io_f = File.new(file, 'r')
  stream_file(@route , io_f, true)
elsif post == :stream
  stream_io(@route , STDIN, true)
elsif del == true
  then
  perform_del
else
  perform_get
end