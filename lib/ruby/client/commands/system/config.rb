case ARGV[2]

when 'set'

  case ARGV[3]
  when 'default_domain'
    @route += '/' + ARGV[3]
  when 'default_site'
    @route += '/' + ARGV[3]
  when 'hostname'
    @route += '/' + ARGV[3]
end
  perform_post(ARGV[3])
  
when 'remote_exception_logging'
  @route += '/' + ARGV[2] 
  if ARGV.count == 4
    @route += '/' + ARGV[3]
   end
  
when 'default_domain'
  @route += '/' + ARGV[2]
when 'default_site'
  @route += '/' + ARGV[2]
when 'hostname'
  @route += '/' + ARGV[2]
when 'remote_exception_logging'
  @route += '/' + ARGV[2]
end

perform_get
