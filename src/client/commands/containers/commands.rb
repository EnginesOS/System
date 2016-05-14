@route += '/' + ARGV[0] + '/' + ARGV[1] + '/'

case ARGV[1]
when 'changed'
  perform_get
when 'events'
  perform_get
end