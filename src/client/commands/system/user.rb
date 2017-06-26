@route += ''

if ARGV[2] == 'change'
  case ARGV[3]
  when 'email'
    pargs = { current_password: ARGV[5], email: ARGV[6]}
  when 'password'
    pargs = { current_password: ARGV[5], new_password: ARGV[6]}
  end
@route += '/' + ARGV[4]
STDERR.puts(' ' + @route.to_s + ':' + pargs.to_s)
  perform_post(pargs)
else
  @route += '/' + ARGV[2]
end
