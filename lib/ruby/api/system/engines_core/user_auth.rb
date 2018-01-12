module UserAuth
  require "sqlite3"

  def user_login(params)
    q = 'select authtoken from systemaccess where username=' + "'" + params[:user_name].to_s +
    "' and password = '" + params[:password].to_s + "';"
    rows = auth_database.execute(q)
    raise EnginesException.new(error_hash("failed to select " + q.to_s, params)) unless rows.count > 0
    record_login(params)
    rows[0]
  end
  
  def record_login(params)
    STDERR.puts(Time.now.to_s + ':' + params[:user_name] + ':' + params[:src_ip] )
  end

  def is_token_valid?(token, ip = nil)
    ip = nil
    if ip == nil
      rows = auth_database.execute(\
      'select guid from systemaccess where authtoken=' + "'" + token.to_s + "';" )
    else
      rows = auth_database.execute(\
        'select guid from systemaccess where authtoken=' + "'" + token.to_s + "' and ip_addr ='';")
      if rows.count == 0
        rows = auth_database.execute(\
          'select guid from systemaccess where authtoken=' + "'" + token.to_s + "' and ip_addr ='" + ip.to_s + "';" )
      end
    end
    if rows.count > 0
      true
    else
      false
    end
  rescue StandardError => e
    STDERR.puts('token verify error  ' + e.to_s)
    STDERR.puts('token verify error exception name  ' + e.class.name)
    false
  end

  def auth_database
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.nil?
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.is_a?(FalseClass)
    $auth_db = SQLite3::Database.new SystemConfig.SystemAccessDB if $auth_db.closed?
    $auth_db
  rescue StandardError => e
    STDERR.puts('Exception failed to open sql_lite_database: ' + e.to_s)
    false
  end

  def init_system_password(password,  token = nil)
    SystemDebug.debug(SystemDebug.first_run, :applyin, password)
    set_system_user_password('admin', password,  token)
    SystemDebug.debug(SystemDebug.first_run, :applied, password)
  end

  def get_system_user_info(user_name)
    rws = auth_database.execute("Select username,  authtoken, uid from systemaccess where username = '" + user_name.to_s + "';")
    { user_name: rws[0][0],
      auth_token: rws[0][1],
      uid: rws[0][2],
    }if rws[0].is_a?(Array)
  end

  #[:user_name,   | :new_password  & :current_password])
  def set_system_user_details(params)
    if params[:current_password].nil?
      raise EnginesException.new(
      level: :warning,
      params: params,
      status: nil,
      system: 'user auth',
      error_mesg: 'Missing Password')
    else
      rws = auth_database.execute("Select authtoken from systemaccess where username = '" + params[:user_name]\
      + "' and password = '" + params[:current_password] + "';")
      if rws.nil? || rws.count == 0
        raise EnginesException.new(
        level: :warning,
        error_type: :warning,
        params: params,
        status: nil,
        system: 'user auth',
        error_mesg: 'Username password missmatch')
      else      
        unless params[:new_password].nil?
          authtoken = SecureRandom.hex(64)
          query = "UPDATE systemaccess SET password = '"\
          +  params[:new_password] + "', authtoken ='" + authtoken.to_s \
          + "' where username = '" + params[:user_name] + "' and password = '" + params[:current_password] + "';"
          auth_database.execute(query)
          update_local_token(authtoken) if params[:user_name] == 'admin'
        end
      end
    end
  end

  def set_system_user_password(user, password, token, current_password = nil)
    if current_password.nil?
      rws = auth_database.execute("Select authtoken from systemaccess where username = '" + user.to_s + "';")
    else
      rws = auth_database.execute("Select authtoken from systemaccess where username = '" + user.to_s\
      + "' and password = '" + current_password.to_s + "';")
    end
    authtoken = SecureRandom.hex(64)
    if rws.nil? || rws.count == 0
      query = 'INSERT INTO systemaccess (username, password,  authtoken, uid)
                 VALUES (?, ?, ?, ?, ?)'
      SystemDebug.debug(SystemDebug.first_run,:applyin,  query, [user, password, authtoken, 0])
      auth_database.execute(query, [user, password, authtoken, 0])
      update_local_token(authtoken) if user == 'admin'
    else
      token = rws[0][0] if token.nil? # FIXMe should be if first run?
      raise EnginesException.new(
      level: :warning,
      params: nil,
      status: nil,
      system: 'user auth',
      error_mesg: 'token missmatch') if token != rws[0][0]
      query = "UPDATE systemaccess SET password = '"\
      + password.to_s  \
      + "', authtoken ='" + authtoken.to_s \
      + "' where username = '" + user + "' and authtoken = '" + token.to_s + "';"
      SystemDebug.debug(SystemDebug.first_run,:applyin, query)
      auth_database.execute(query)
      update_local_token(authtoken) if user == 'admin'
    end
    authtoken
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.first_run,"Exception ", e)
    log_error_mesg(e.to_s)
    auth_database.close
    true
  end

  def update_local_token(token)
    SystemDebug.debug(SystemDebug.first_run, ' Save Token', token)
    toke_file = File.new('/home/engines/.engines_token', 'w+')
    toke_file.puts(token)
    toke_file.close
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.first_run,"Exception ", e)
    log_error_mesg(e.to_s)
  end

end