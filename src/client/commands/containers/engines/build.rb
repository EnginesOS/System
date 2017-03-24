params_data = read_stdin_data
command_usage unless params_data.is_a?(String)
#STDERR.puts(json_parser.parse(params_data).to_s)
perform_post(json_parser.parse(params_data))