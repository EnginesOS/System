
params = read_stdin_data
command_useage unless params.is_a?(String)
perform_post(params.to_json)
  
