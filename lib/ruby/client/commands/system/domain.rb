case ARGV[2]
when 'view'
  @route += '/' + ARGV[3]
  perform_get

when 'update'
  @route += '/' + ARGV[3]
  params_data = read_stdin_data
  command_useage unless params_data.is_a?(String)
  perform_post(JSON.parse(params_data))

end