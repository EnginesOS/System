if ARGV.count == 2
  @route += '/'
  perform_get
end


case ARGV[2]


when 'add'
@route += '/' + ARGV[2]
perform_post(params)
when 'remove'
@route += '/' + ARGV[2]
perform_delete
end


