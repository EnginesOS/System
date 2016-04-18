case ARGV[3]
when 'restart'
@route += '/' + ARGV[3]
when 'update'
@route += '/' + ARGV[3]
when 'shutdown'
@route += '/' + ARGV[3]
end
perform_get