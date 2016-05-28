# @!group /system/login

# Login with :user_name and :password
# @method login
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do 
  $token = 'test_token_arandy'
 p $token
  p $token.to_json.to_s
  return $token.to_json
end

# @clears Authentication token
get '/v0/logout' do
  $token = ''
end

# Called in response to an unauthorised post request
# returns error hash
post '/v0/unauthenticated' do     
    log_error(request,nil,'unauthorised', params).to_json
  end

# Called in response to an unauthorised get request
# returns error hash   
  get  '/v0/unauthenticated' do     
  log_error(request,nil,'unauthorised', params).to_json
end

