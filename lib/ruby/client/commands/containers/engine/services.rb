@route += '/'
if ARGV.count == 4
  perform_get
end

n = 5
len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

perform_get
