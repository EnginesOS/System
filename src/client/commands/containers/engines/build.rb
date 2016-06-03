params_data = read_stdin_data
command_useage unless params_data.is_a?(String)
STDERR.puts(JSON.parse(params_data, :create_additons => true ).to_s)
perform_post(JSON.parse(params_data, :create_additons => true ))