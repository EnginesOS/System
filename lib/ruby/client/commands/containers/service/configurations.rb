@route += '/' + ARGV[3] + '/'
if ARGV.count == 4
  perform_get
end

case  ARGV[4]
when 'run'
@route += '/' + ARGV[5]
params = read_stdin_data
perform_post(params)
end
@route += '/' + ARGV[4]
perform_get
