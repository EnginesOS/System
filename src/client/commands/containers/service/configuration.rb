
case  ARGV[3]
when 'run'
@route += '/' + ARGV[4]
params_data = read_stdin_json
p params_data
perform_post(params_data)
end
@route += '/' + ARGV[3]
perform_get
