@route += '/' + ARGV[2]

return command_useage unless ARGV[3].is_a?(String)

params={}
  params[:string] =  ARGV[3]
perform_post(params)
