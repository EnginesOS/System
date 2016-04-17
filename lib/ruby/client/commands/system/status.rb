
if ARGV.count < 3
  p ARGV.count
  perform_get
end 


case ARGV[2]

when 'first_run'
@route += '/' + 'first_run_has_run'
  perform_get
end