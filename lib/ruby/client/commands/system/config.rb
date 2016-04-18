case ARGV[2]

when 'set'
  params = {}
  case ARGV[3]
  when 'default_domain'
    @route += '/' + ARGV[3]
    params[:default_domain] =  ARGV[4]
  when 'default_site'
    @route += '/' + ARGV[3]
    params[:default_site] =  ARGV[4]
  when 'hostname'
    @route += '/' + ARGV[3]
    params[:host_name] =  ARGV[4]
  end
  perform_post(params)

when 'remote_exception_logging'
  @route += '/' + ARGV[2]
  if ARGV.count == 4
    @route += '/' + ARGV[3]
    perform_post()
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
