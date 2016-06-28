
@route += '/' + ARGV[0] + '/' + ARGV[1] 
if ARGV[1] == 'follow'
  @route += '_stream'
  get_stream(@route)
else
  @route += '/' + ARGV[2] if ARGV.count >= 3
  perform_get
end