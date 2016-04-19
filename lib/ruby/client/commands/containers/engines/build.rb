params_data = read_stdin_data
command_useage unless params_data.is_a?(String)
perform_post(JSON.parse(params_data))