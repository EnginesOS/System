@route += '/orphan_service/'
p @route
if ARGV.count == 4
  @route +=   ARGV[2] +  '/' + ARGV[3]
elsif ARGV.count == 5
@route +=   ARGV[2] +  '/' + ARGV[3]+  '/' + ARGV[4]
end 

perform_get