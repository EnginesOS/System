puts 'argv3' +  ARGV[3].to_s
case ARGV[3]
 
when 'generate'
@route += '/' + ARGV[4] + '/generate'
 
when 'update'
params = {} 
 perform_post(param)
  
else
@route += '/' + ARGV[3]
end

perform_get