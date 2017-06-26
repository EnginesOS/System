@route += ''

if ARGV[2] == 'change'

  case ARGV[3]
  when 'email'
    pargs = { user_name: ARGV[4], current_password: ARGV[5], email: ARGV[6]}
  when 'password'
    pargs = { user_name: ARGV[4], current_password: ARGV[5], new_password: ARGV[6]}
  end
  perform_post(pargs)
else
  @route += '/' + ARGV[2]
end
