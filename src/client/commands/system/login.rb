@route += '/'
p = {api_vars: {user_name: ARGV[2],
  password: ARGV[3]
  }}

perform_post(p.to_json)