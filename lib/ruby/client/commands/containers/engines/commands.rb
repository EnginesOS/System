if ARGV.count ==1
  @route += '/'
  perform_get
end

@route += '/' + ARGV[1]
case ARGV[1]
when 'state'
perform_get
when 'container_name'
perform_get

end