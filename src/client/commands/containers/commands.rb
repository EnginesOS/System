@route += '/' + ARGV[0] + '/' + ARGV[1] 

case ARGV[1]
when 'changed'
  perform_get
when 'events'
get_json_stream(@route + '/stream' )
 
end
perform_get