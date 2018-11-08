@route += '/orphan_service/'
STDERR.puts('Arg Count ' + ARGV.count.to_s)
STDERR.puts('route ' + @route.to_s)
if ARGV.count == 5
  @route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4]
elsif ARGV.count == 6
  @route +=   ARGV[2] + '/' + ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5]
end
if ARGV[2] == 'delete'
  @route +=   ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5] + '/' + ARGV[6]
  perform_delete
elsif ARGV[2] == 'export'
  @route +=   ARGV[3] + '/' + ARGV[4] + '/' + ARGV[5]

end
STDERR.puts('route ' + @route.to_s)
perform_get