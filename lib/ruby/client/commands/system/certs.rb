@route += '/' + ARGV[2]
case ARGV[2]
when 'system_ca'

when 'list'
@route += '/' + ARGV[2]
when 'view'
@route += '/' + ARGV[2]
when 'remove'
@route += '/' + ARGV[2]
when 'update'
@route += '/' + ARGV[2]
end