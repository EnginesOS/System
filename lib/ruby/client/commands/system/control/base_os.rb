case ARGV[3]
when 'restart'
@route += '/' + ARGV[3]
when 'update'
@route += '/' + ARGV[3]
when 'shtudown'
@route += '/' + ARGV[3]
end
perform_get