@route += '/'

cmd = nil

case ARGV[3]
when 'register'
  cmd = ARGV[3]
when 'deregister'
 cmd = ARGV[3]
when 'reregister'
 cmd = ARGV[3]
end

if cmd.nil?
  n = 3
else
  n = 4
end

len = ARGV.count
while n < len
  @route += '/' + ARGV[n]
  n += 1
end

@route += '/' + cmd unless cmd.nil?


perform_get