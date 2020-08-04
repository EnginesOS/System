# @!group /system/login

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
    if cparams[:user_name].nil?
      cparams[:password] = nil
      raise EnginesException.new(error_hash("User name cant be blank", cparams))
    else
      if request.env.key?('HTTP_X_FORWARDED_FOR')
        cparams[:src_ip] = request.env['HTTP_X_FORWARDED_FOR']
      else
        cparams[:src_ip] = request.env['REMOTE_ADDR']
      end
      engines_api.user_login(cparams)
    end
  rescue StandardError => e
    send_encoded_exception(status: 401, request: request, exception: e)
  end
end
# Login with :user_name and :password
# @method login
# @overload  post '/v0/system/login/'
# @params :user_name, :password
# @return [String] Authentication token
#post '/v0/system/loginb' do
#  begin
#    content_type 'text/plain'
#    post_s = post_params(request)
#    cparams = assemble_params(post_s, nil, [:user_name, :password])
#    cparams[:src_ip] = request.env['REMOTE_ADDR']
#    cparams[:user_name] = ''
#    cparams[:password] = ''
#
#    engines_api.user_login(cparams)
#  rescue StandardError => e
#    send_encoded_exception(status: 401, request: request, exception: e)
#  end
#end

post '/v0/system/logout' do
  begin
    status(403)
    post_s = post_params(request)
    cparams = assemble_params(post_s, [:user_toke])
    engines_api.log_out_user(cparams)
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
