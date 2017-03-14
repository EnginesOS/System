if ARGV.count < 3
  perform_get
end

case ARGV[2]

when 'first_run_required'
  @route += '/' + 'first_run_required'
  perform_get
end
@route += '/' + ARGV[2] unless  ARGV[2].nil?  
perform_get