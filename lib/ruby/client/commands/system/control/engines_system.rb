p 'arg3' +  ARGV[3]
case ARGV[3]
when 'restart'
@route += '/' + ARGV[3]
when 'update'
@route += '/' + ARGV[3]
when 'recreate'
@route += '/' + ARGV[3]
end

perform_get