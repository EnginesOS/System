@route += '/' + ARGV[3]
case ARGV[3]
when 'runtime'
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
when 'network'
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
end
