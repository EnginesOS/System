@route += '/' + ARGV[0] + '/'

case ARGV[2]
when 'wait_for'
  @route += '/' + ARGV[1] + '/' + ARGV[2]
  @route += '/' + ARGV[3] if ARGV[1].length == 4
  perform_get
end
