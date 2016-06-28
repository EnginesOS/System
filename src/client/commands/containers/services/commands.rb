@route += '/containers/' + ARGV[0] + '/'
if ARGV.count == 1
  perform_get
end

@route +=  ARGV[1]
perform_get