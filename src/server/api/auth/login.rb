# @!group /system/login

# Login with :user_name and :password
# @method login
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do
  begin
    content_type 'text/plain'
    engines_api.user_login(params)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# Login with :user_name and :password
# @method login
# @overload  post '/v0/system/login/'
# @params :user_name, :password
# @return [String] Authentication token
post '/v0/system/login' do
  begin
    content_type 'text/plain'
    post_s = post_params(request)
    cparams = assemble_params(post_s, nil, [:user_name, :password])
    engines_api.user_login(cparams)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @clears Authentication token
# FIXMe this is a no-op
get '/v0/system/logout' do
  begin
    status(403)
    ''
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# Called in response to an unauthorised post request
# returns error hash
post '/v0/unauthenticated' do
  begin
    send_encoded_exception(request, nil, 'unauthorised', params)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# Called in response to an unauthorised get request
# returns error hash
get '/v0/unauthenticated' do
  begin
    # send_encoded_exception(request: nil, exception: 'unauthorised', params: params)
    status(403)
    ''
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
