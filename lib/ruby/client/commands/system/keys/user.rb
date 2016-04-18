puts 'argv3' +  ARGV[3].to_s
case ARGV[3]
 
when 'generate'
@route += '/' + ARGV[4] = '/generate'
 
when 'update'
params = {} 
 perform_post(param)
  
when 'view'
@route += '/engines'
end

perform_get