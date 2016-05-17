get '/v0/system/login/:user_name/:password' do 
  #access_token = 'test_token'
  $token = 'test_token_arandy'
 p $token
  p $token.to_json.to_s
  return $token.to_json
end

get '/v0/logout' do
  $token = ''
end

post '/v0/unauthenticated' do     
    log_error(request,nil,'unauthorised', params).to_json
  end
  
  get  '/v0/unauthenticated' do     
  log_error(request,nil,'unauthorised', params).to_json
end

