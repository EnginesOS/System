perform_get unless ARGV.count > 3
@route += '/' + ARGV[3] + '/'
n = 4
 if ARGV[3] == 'add'
post = true
STDERR.puts  @route
params[:data] = read_stdin_data
n = 4
end

if ARGV.count == 4
  perform_get  
end

n = 4
len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

if post == true
  perform_post(params)
else
perform_get
end
