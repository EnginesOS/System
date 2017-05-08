case ARGV[3]
when 'restart'
  @route += '/' + ARGV[3]
when 'update'
  @route += '/' + ARGV[3]
when 'shutdown'
  @route += '/' + ARGV[3]
  params = {}
  params[:reason] = ARGV[4]
  perform_post(params)
when 'timezone'
  @route += '/' + ARGV[3] 
when 'locale' 
  @route += '/' + ARGV[3]
when 'set'
  case ARGV[4]
when 'timezone'
@route += '/' + ARGV[3]
params = {}
 params[:timezone] = ARGV[5]
   perform_post(params)
when 'locale' 
@route += '/' + ARGV[3]
params = {}
 params[:country_code] = ARGV[5]
 params[:lang_code]  = ARGV[6]
 perform_post(params)
end
end
perform_get