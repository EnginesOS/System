# @!group /system/login

# Login with :user_name and :password
# @method login
# @overload get '/v0/system/login/:user_name/:password'
# @return [String] Authentication token
get '/v0/system/login/:user_name/:password' do 
  begin
 # auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if @auth_db.nil?
 # auth_db = sql_lite_database
  content_type 'text/plain'
  $token = engines_api.user_login(params)
#  rows = sql_lite_database.execute( 'select authtoken from systemaccess where username=' + "'" + params[:user_name].to_s + 
#    "' and password = '" +  params[:password].to_s + "'")
##  auth_db.close
#  return log_error(request,nil,'unauthorised', params) unless rows.count > 0
#  
# 
#  $token = rows[0]
  return $token
    rescue StandardError =>e
      log_error(request, e)
    end
end

# @clears Authentication token
get '/v0/logout' do
  begin
  $token = ''
  rescue StandardError =>e
    log_error(request, e)
  end
end

# Called in response to an unauthorised post request
# returns error hash
post '/v0/unauthenticated' do     
  begin
    log_error(request,nil,'unauthorised', params)
    rescue StandardError =>e
      log_error(request, e)
    end
  end

# Called in response to an unauthorised get request
# returns error hash   
  get  '/v0/unauthenticated' do     
    begin
  log_error(request,nil,'unauthorised', params)
      rescue StandardError =>e
        log_error(request, e)
      end
end

