# @!group /system/login

# Login with :user_name and :password
# @method login_deprecated
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do
  begin
    content_type 'text/plain'
    STDERR.puts('USING INSECURE DEPRECATED METHOD')
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
    send_encoded_exception(status: 401, request: request, exception: e)
  end
end

# Set Users details
# @method set_user
# @overload post '/v0/system/users/'
# @params :user_name, :new_password, :email, :token, :current_password
# all params are required
# new auth token returned
post '/v0/system/users/' do
begin
  content_type 'text/plain'
  post_s = post_params(request)
  cparams = assemble_params(post_s, nil, [:user_name, :new_password, :email, :token, :current_password])
  return_boolean(engines_api.set_system_user_password(cparams))
rescue StandardError => e
  send_encoded_exception(request: request, exception: e)
end
end

# Set Users details
# @method mod_system_user
# @overload post 'v0/system/user/:user_name'
# @params  :new_password, :email, , :current_password
# :user_name and params are required
# password is changed if new_password present
# email is changed if email is present

post '/v0/system/user/:user_name' do
begin
  content_type 'text/plain'
  post_s = post_params(request).merge(params)
  cparams = assemble_params(post_s, [:user_name], nil, [:new_password, :email, :current_password])
  return_boolean(engines_api.set_system_user_details(cparams))
rescue StandardError => e
  send_encoded_exception(request: request, exception: e)
end
end

# get Users details
# @method get_user
# @overload get '/v0/system/user/:user_name'
#
# @return user params["user_name, :token, :email, :uid] 
get '/v0/system/user/:user_name' do
begin
  content_type 'text/plain'
  cparams = assemble_params(params, [:user_name])
  return_json(engines_api.get_system_user_info(cparams[:user_name]))
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
    STDERR.puts('post UNAUTH ROTE')
    status(403)
    send_encoded_exception(request: request, exception: 'unauthorised', params: params)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# Called in response to an unauthorised get request
# returns error hash
get '/v0/unauthenticated' do
  begin
    STDERR.puts('get UNAUTH ROTE')
    # send_encoded_exception(request: nil, exception: 'unauthorised', params: params)
    status(403)
    ''
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
