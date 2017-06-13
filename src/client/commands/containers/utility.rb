@route += '/' + ARGV[0] + '/'

case ARGV[1]
when 'wait_for'
  @route += '/' + ARGV[1] + '/' + ARGV[2]
  @route += '/' + ARGV[3] if ARGV[1].count == 4
  perform_get
end
