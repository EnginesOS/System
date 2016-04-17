
case ARGV[2]

when 'list'
@route += '/'
  perform_get
when 'remove'
  @route += '/' + ARGV[3]
  perform_get
when 'add'
@route += '/'
  params_data = read_stdin_data
  command_useage unless params_data.is_a?(String)
  perform_post(JSON.parse(params_data))
end