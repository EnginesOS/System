perform_get unless ARGV.count > 3
@route += '/' + ARGV[3] + '/'
if ARGV.count == 4
  perform_get
end

n = 4
len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

perform_get
