@route += ''
last_arg = ARGV.count - 1
if last_arg > 3
  cn_end = last_arg - 1
  un = ARGV[2-cn_end]
else
  un = ARGV[2]
end
ps =  {user_name: un,
  password: ARGV[last_arg]
  }

perform_post(ps)