case ARGV[3]
when 'restart'
  @route += '/' + ARGV[3]
when 'update'
  @route += '/' + ARGV[3]
when 'shutdown'
  @route += '/' + ARGV[3]
  params = {}
  params[:reason] =  ARGV[4]
  perform_post(params)

end
perform_get