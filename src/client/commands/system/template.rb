command_usage unless ARGV[2].is_a?(String)

params={}
params[:string] =  ARGV[2]
perform_post(params)
