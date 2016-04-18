@route += '/containers/' + ARGV[0] + '/' + ARGV[1]
perform_get if ARGV.count == 2

@route += '/' + ARGV[2]


perform_get 
