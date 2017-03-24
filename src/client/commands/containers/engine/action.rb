if ARGV.count == 5
  @route += '/' + ARGV[4]   
  params_data = read_stdin_data
command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
end
  
@route += '/' + ARGV[3]
