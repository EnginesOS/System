@route += '/orphan_service/'

if ARGV.count == 5
  @route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4]
elsif ARGV.count == 6
@route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5]
elsif ARGV[2] == 'delete'
@route +=   ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5] + '/' + ARGV[6]
perform_delete
end 

perform_get