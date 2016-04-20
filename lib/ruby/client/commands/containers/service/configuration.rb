

case  ARGV[3]
when 'run'
@route += '/' + ARGV[4]
params = read_stdin_data
perform_post(params)
end
@route += '/' + ARGV[3]
perform_get
