# @!group /system/login

# Login with :user_name and :password
# @method login
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do 
  @auth_db = SQLite3::Database.new "/home/app/db/production.sqlite3"
  rows = @auth_db.execute( 'select authtoken from systemaccess where username=' + "'" + params[:user_name].to_s + 
    "' and password = '" +  params[:password].to_s + "'")

  return log_error(request,nil,'unauthorised', params) unless rows.count > 0
  
  content_type 'text/plain'
  $token = rows[0]
  return $token
end

# @clears Authentication token
get '/v0/logout' do
  $token = ''
end

# Called in response to an unauthorised post request
# returns error hash
post '/v0/unauthenticated' do     
    log_error(request,nil,'unauthorised', params)
  end

# Called in response to an unauthorised get request
# returns error hash   
  get  '/v0/unauthenticated' do     
  log_error(request,nil,'unauthorised', params)
end

