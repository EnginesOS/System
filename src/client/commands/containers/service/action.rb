if ARGV.count == 5
  @route += '/' + ARGV[4]   
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(JSON.parse(params_data), :create_additons => true )
end
  
@route += '/' + ARGV[3]
