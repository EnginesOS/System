case ARGV[2]

when 'view'
  @route += '/' + ARGV[3]
  perform_get

when 'update'
  @route += '/' + ARGV[3]
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))


when 'list'
  @route += '/'
  perform_get
when 'remove'
  @route += '/' + ARGV[3]
  perform_delete
when 'add'
  @route += '/'
  params_data = read_stdin_data
  command_usage unless params_data.is_a?(String)
  perform_post(json_parser.parse(params_data))
end