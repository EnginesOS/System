class EnginesCore
  require "sqlite3"

  def user_login(params)
    if params[:user_name].to_s == 'admin'
      admin_user_login(params)
    else
      ldap_user_login(params)
    end
   
  end

  def get_system_user_info(user_name)
    rws = auth_database.execute("Select username,  authtoken, uid from systemaccess where username = '" + user_name.to_s + "';")
    { user_name: rws[0][0],
      auth_token: rws[0][1],
      uid: rws[0][2],
    }if rws[0].is_a?(Array)
  ensure
    auth_database.close
  end

  def set_system_user_details(params)
    if params[:current_password].nil?
      raise EnginesException.new(
      level: :warning,
      error_type: :warning,
      params: params,
      status: nil,
      system: 'user auth',
      error_mesg: 'Missing Password')
    else
      rws = auth_database.execute("Select authtoken from systemaccess where username = '#{params[:user_name]}' and password = '#{params[:current_password]}';")
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
          query = "UPDATE systemaccess SET password = '#{params[:new_password]}', authtoken ='#{authtoken}' where username = '#{params[:user_name]}' and password = '#{params[:current_password]}';"
          auth_database.execute(query)
          update_local_token(authtoken) if params[:user_name] == 'admin'
        end
      end
    end
  ensure
    auth_database.close
  end

  def set_system_user_password(password, token, current_password = nil)
    user = 'admin'
    SystemDebug.debug(SystemDebug.first_run,:applyin,  query, [user, password, authtoken, 0])
    if current_password.nil?
      rws = auth_database.execute("Select authtoken from systemaccess where username = '#{user}';")
    else
      rws = auth_database.execute("Select authtoken from systemaccess where username = '#{user}' and password = '#{current_password}';")
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
      error_type: :warning,
      params: nil,
      status: nil,
      system: 'user auth',
      error_mesg: 'token missmatch') if token != rws[0][0]
      query = "UPDATE systemaccess SET password = '#{password}', #{authtoken} ='#{authtoken}' where username = '#{user}' and authtoken = '#{token}';"
       SystemDebug.debug(SystemDebug.first_run,:applyin, query)
      auth_database.execute(query)
      update_local_token(authtoken) if user == 'admin'
    end

    authtoken
  rescue StandardError => e
    #   SystemDebug.debug(SystemDebug.first_run,"Exception ", e)
    log_error_mesg(e.to_s)
    auth_database.close
    true
  ensure
    auth_database.close
  end

  def system_user_settings
    if File.exist?(SystemConfig.SystemUserSettingsFile)
      data = File.read(SystemConfig.SystemUserSettingsFile)
      YAML::load(data)
    else
      {}
    end
  rescue
    {}
  end

  def set_system_user_settings(settings)
    sf = File.new(SystemConfig.SystemUserSettingsFile, 'w+')
    begin
      sf.write(settings.to_yaml)
    ensure
      sf.close
    end
    true
  rescue StandardError => e
    sf.close unless sf.nil?
    raise e
  end

  def is_admin_token_valid?(token, ip = nil)
    ip = nil
    STDERR.puts("is_admin_token_valid TOKEN #{token}")
    if ip.nil?
      rows = auth_database.execute(\
      "select guid from systemaccess where authtoken='#{token}';" )
    else
      rows = auth_database.execute(\
      "select guid from systemaccess where authtoken='#{token}' and ip_addr ='';")
      if rows.count == 0
        rows = auth_database.execute(\
        "select guid from systemaccess where authtoken='#{token}' and ip_addr ='{ip}';" )
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
  ensure
    auth_database.close
  end

  def is_user_token_valid?(token, ip = nil)
 STDERR.puts("Is use token #{token} valid ")
    unless token.nil?
      if is_admin_token_valid?(token, ip)
        access = true
      else
        #   STDERR.puts('USER TOKENS ' + $user_tokens.to_s)
        access = $user_tokens.key?(token)
        #   STDERR.puts('USER Access ' + access.to_s)
      end
    else
      access = false
    end
    access
  rescue
    false
  end

  def get_token_user(token)
    if  $user_tokens.key?(token)
      user_params = $user_tokens[token]
      if user_params.is_a?(Hash)
        user_params[:user_name]
      else
        nil
      end
    else
      nil
    end
  end

  def init_system_password(password,  token = nil)
    # SystemDebug.debug(SystemDebug.first_run, :applyin, password)
    set_system_user_password(password,  token)
    # SystemDebug.debug(SystemDebug.first_run, :applied, password)
  end
  
  private

  def ldap_user_logout(tok)
    $user_tokens.delete(tok) if $user_tokens.key?(tok)
  end

  def ldap_user_login(params)
    require 'net/ldap'
    ldap = Net::LDAP.new
    ldap.host = 'ldap'
    ldap.port = 389
    # STDERR.puts('LDAP LOGIN PARAMS ', params.to_s )
    ldap.auth(params[:user_name], params[:password])
    if ldap.bind
      tok =  SecureRandom.hex(48)
      $user_tokens[tok] = params
      record_login(params)
      tok
      # authentication succeeded
    else
      # authentication failed
      raise EnginesException.new(error_hash("failed to bind " + ldap.get_operation_result.message.to_s ,params))
    end
  end

  def admin_user_login(params)
    STDERR.puts("admin_user_login #{params}  ")
    q = "select authtoken from systemaccess where username='#{params[:user_name]}' and password = '#{params[:password]}';"
    rows = auth_database.execute(q)
    raise EnginesException.new(error_hash("failed to select " + q.to_s, params)) unless rows.count > 0
    record_login(params)
    rows[0]
  ensure
    auth_database.close
  end

  def record_login(params)
    #FIXME save to file
    STDERR.puts(Time.now.to_s + ':' + params[:user_name] + ':' + params[:src_ip] )
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

  #[:user_name,   | :new_password  & :current_password])

  def update_local_token(token)
    #  SystemDebug.debug(SystemDebug.first_run, ' Save Token', token)
    toke_file = File.new('/home/engines/.engines_token', 'w+')
    begin
      toke_file.puts(token)
    ensure
      toke_file.close
    end
  rescue StandardError => e
    #   SystemDebug.debug(SystemDebug.first_run,"Exception ", e)
    log_error_mesg(e.to_s)
  end

end