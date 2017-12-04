command_usage unless ARGV[2].is_a?(String)

params={}
params[:template_string] =  ARGV[2]
perform_post(params)
