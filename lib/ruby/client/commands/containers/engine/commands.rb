@route += '/containers/' + ARGV[0] + '/' + ARGV[1]
perform_get if ARGV.count == 2



case ARGV[2]
when 'destroy'
@route += '/' + ARGV[2]
  perform_delete
when 'delete_image'
@route += '/' + ARGV[2]
perform_delete

when 'mem_stat'
@route += '/metrics/memory'

when 'net_stat'
@route += '/metrics/network'

end

@route += '/' + ARGV[2]
perform_get  

