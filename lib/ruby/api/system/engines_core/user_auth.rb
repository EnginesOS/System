module UserAuth
  require "sqlite3"
   def  auth_database
   $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.nil?
   $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.is_a?(FalseClass)
   $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.closed?
   $auth_db
 rescue StandardError => e
   STDERR.puts('Exception failed to open  sql_lite_database: ' + e.to_s)
   return false
 end
    
   def init_system_password(password,email, token = nil)
     set_system_user_password('admin',password,email, token)
   end
   
   def set_system_user_password(user,password,email, token= nil)
 
 
     
     rws = auth_database.execute("Select * from systemaccess where  username = '" + user.to_s + "'")
     
     if rws.count == 0
       authtoken = SecureRandom.hex(128)
       auth_database.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid) 
                 VALUES (?, ?, ?, ?,?)", [username, password, email.to_s, authtoken,0,0])
     else
     authtoken = SecureRandom.hex(128)
     auth_database.execute("UPDATE systemaccess SET password = '" \
         + password.to_s + "',email='" + email.to_s + \
         ", authtoken ='" + authtoken.to_s + "' " + \
         " where username = 'admin' and authtoken = '" + token.to_s + '"')                
     end   
     
         
     # FIXME REMOVE once all installs use proper auth            
    # db.execute("INSERT INTO systemaccess (name, password, email, authtoken, uid) 
     #               VALUES (?, ?, ?, ?,?)", ["admin", 'test', email.to_s, 'test_token_arandy',1,0])
 
   rescue StandardError => e
     log_error_mesg(e.to_s)
     db.close
     return true          
   end
   
   
end