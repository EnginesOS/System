if ARGV.count < 3
  perform_get
end 

@route += '/' + ARGV[2]
case ARGV[2]

when 'first_run'
  perform_get
end