module UserAuth
  require "sqlite3"

  def user_login(params)
    
    rows = auth_database.execute( 'select authtoken from systemaccess where username=' + "'" + params[:user_name].to_s +
    "' and password = '" +  params[:password].to_s + "';")
      
    raise EnginesException.new(error_hash("failed to select", params)) unless rows.count > 0
    rows[0]
  end

  def is_token_valid?(token, ip =nil)

    if ip == nil
      rows = auth_database.execute( 'select guid from systemaccess where authtoken=' + "'" + token.to_s + "';" )
    else
      rows = auth_database.execute( 'select guid from systemaccess where authtoken=' + "'" + token.to_s + "' and ip_addr ='" + ip.to_s + "';" )
    end
    return false unless rows.count > 0
     rows[0]
  rescue StandardError => e
    STDERR.puts(' toekn verify error  ' + e.to_s)
    STDERR.puts(' toekn verify error exception name  ' + e.class.name)
     false

  end

  def  auth_database
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.nil?
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.is_a?(FalseClass)
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.closed?
    $auth_db
  rescue StandardError => e
    STDERR.puts('Exception failed to open  sql_lite_database: ' + e.to_s)
     false
  end

  def init_system_password(password,email, token = nil)
    SystemDebug.debug(SystemDebug.first_run,:applyin, password,email)
    set_system_user_password('admin',password,email, token)
  end

  def set_system_user_password(user,password,email, token= nil)

    rws = auth_database.execute("Select * from systemaccess where  username = '" + user.to_s + "';")

    if rws.count == 0
      authtoken = SecureRandom.hex(128)
      auth_database.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid)
                 VALUES (?, ?, ?, ?,?)", [username, password, email.to_s, authtoken,0,0])
                 
    SystemDebug.debug(SystemDebug.first_run,:applyin, "UPDATE systemaccess SET password = '" \
       + password.to_s + "',email='" + email.to_s + \
       "INSERT INTO systemaccess (username, password, email, authtoken, uid)
    VALUES (?, ?, ?, ?,?)", [username, password, email.to_s, authtoken,0,0])
    else
      authtoken = SecureRandom.hex(128)
      auth_database.execute("UPDATE systemaccess SET password = '" \
      + password.to_s + "',email='" + email.to_s + \
      ", authtoken ='" + authtoken.to_s + "' " + \
      " where username = 'admin' and authtoken = '" + token.to_s + '";')
    SystemDebug.debug(SystemDebug.first_run,:applyin, "UPDATE systemaccess SET password = '" \
    + password.to_s + "',email='" + email.to_s + \
    ", authtoken ='" + authtoken.to_s + "' " + \
    " where username = 'admin' and authtoken = '" + token.to_s + '";')
    end

  rescue StandardError => e
    log_error_mesg(e.to_s)
auth_database.close
     true
  end

end