@route += '/containers/' + ARGV[0] + '/' + ARGV[1] + '/'

case ARGV[1]
when 'changed'
@route += '/'
perform_get

end