
@route += '/' + ARGV[2]
  
if ARGV.count > 3 && ARGV[3] == 'set'
perform_post(read_stdin_json)
else
perform_get
end