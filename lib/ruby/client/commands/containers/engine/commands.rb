@route += '/containers/' + ARGV[0] + '/' + ARGV[1]
perform_get if ARGV.count == 2

@route += '/' + ARGV[2]

case ARGV[2]
when 'destroy'
  perform_delete
when 'delete_image'
perform_delete
end

perform_get 
