@route += ''
last_arg = ARGV.count - 1
  n = 3
  un = ARGV[2]
  while n < last_arg do
  un = un + ARGV[n]
  n = n + 1
end

ps =  {user_name: un,
  password: ARGV[last_arg]
  }

perform_post(ps)