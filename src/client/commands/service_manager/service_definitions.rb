@route += '/' + ARGV[1]

@route += '/' + ARGV[2] if ARGV.count >= 3


@route += '/' + ARGV[3] if ARGV.count == 4
perform_get