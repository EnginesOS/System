puts 'argv3' +  ARGV[3].to_s
case ARGV[3]
 
when 'generate'
@route += '/' + ARGV[4] + '/generate'
 
when 'set'
params = {} 
params[:public_key] = read_stdin_data
 perform_post(params)
 p :post
  p params
else
@route += '/' + ARGV[3]
end

perform_get