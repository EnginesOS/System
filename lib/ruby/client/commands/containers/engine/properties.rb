@route += '/' + ARGV[3]
case ARGV[3]
when 'runtime'
params_data = read_stdin_data
command_useage unless params_data.is_a?(String)
perform_post(JSON.parse(params_data))
when 'network'
params_data = read_stdin_data
command_useage unless params_data.is_a?(String)
perform_post(JSON.parse(params_data))
end
