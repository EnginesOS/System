perform_get unless ARGV.count > 3
post = false
del = false
n = 4

 if ARGV[3] == 'add'
post = true
#STDERR.puts  @route
params_data = read_stdin_json


n = 4
elsif ARGV[3] == 'del'
  del=true
  n = 4
else
@route += '/' + ARGV[3] + '/'
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
  perform_post(params_data)
elsif del == true
  perform_del
else
perform_get
end
