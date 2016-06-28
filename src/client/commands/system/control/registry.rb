case ARGV[3]
when 'restart'
  @route += '/' + ARGV[3]
  perform_get
when 'update'

end