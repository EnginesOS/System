# @!group /system/login

# Login with :user_name and :password
# @method login
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do
  begin
    content_type 'text/plain'
    $token = engines_api.user_login(params)
    return $token
  rescue StandardError => e
    log_error(request, e)
  end
end

# @clears Authentication token
get '/v0/logout' do
  begin
    $token = ''
  rescue StandardError => e
    log_error(request, e)
  end
end

# Called in response to an unauthorised post request
# returns error hash
post '/v0/unauthenticated' do
  begin
    log_error(request, nil, 'unauthorised', params)
  rescue StandardError => e
    log_error(request, e)
  end
end

# Called in response to an unauthorised get request
# returns error hash
get '/v0/unauthenticated' do
  begin
    log_error(request, nil, 'unauthorised', params)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
