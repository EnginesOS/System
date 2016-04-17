@route += '/' + ARGV[2]
return usage unless ARGV[3].is_a?(String)

params={}
  params[:string] =  ARGV[3]
perform_post(params)
