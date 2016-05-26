@route += '/orphan_service/'

if ARGV.count == 5
  @route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4]
elsif ARGV.count == 6
@route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5]
end 
p @route
perform_get