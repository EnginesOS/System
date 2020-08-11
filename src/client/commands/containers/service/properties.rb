unless ARGV[3] == 'set'
  @route += '/' + ARGV[3]
  perform_get
else
  @route += '/' + ARGV[4]
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
end

