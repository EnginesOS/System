@route += '/'
if ARGV.count == 3
  perform_get
end

n = 3
len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

perform_get
