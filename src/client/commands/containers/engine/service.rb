@route += '/' + ARGV[3] + '/'  #{non_}persistent
params = {}
STDERR.puts 'engine service ns tp sh ' +  @route
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
when 'import_file'
  cmd = ARGV[4]
  post = true
  params[:data] =  'file'
when 'replace_file'
  cmd = ARGV[4]
  post = true
  params[:data] =  'file'

when 'replace'
  cmd = ARGV[4]
  post = true
  STDERR.puts  @route
  params[:data] = read_stdin_data
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
  STDERR.puts  'Posting'  + @route
  perform_post(params, 'application/octet-stream')
else
  perform_get
end