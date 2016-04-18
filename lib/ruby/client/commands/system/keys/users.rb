puts 'argv3' +  ARGV[3].to_s
case ARGV[3]
 
when 'generate'
@route += '/' + ARGV[3]
 
when 'update'
params = {} 
 perform_post(param)
  
when 'view'
@route += '/engines'
end