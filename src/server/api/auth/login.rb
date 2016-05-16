put '/login/:user_name/:password' do 
  access_token = 'test_token'
  access_token.to_json
end

put '/logout' do
  
end
