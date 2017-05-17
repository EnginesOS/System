module UserAuth
  require "sqlite3"

  #  WS in engines Server is needed?
  #  def init_db
  #      create_table
  #      set_first_user
  #    end
  #
  #    def create_table
  #      sql_lite_database.execute <<-SQL
  #              create table systemaccess (
  #                username varchar(30),
  #                email varchar(128),
  #                password varchar(30),
  #                authtoken varchar(128),
  #                ip_addr varchar(64),
  #                ip_mask varchar(64),
  #                uid int,
  #                guid int
  #              );
  #      SQL
  #      true
  #    rescue
  #      true
  #    end
  #
  #    def set_first_user
  #      rows = sql_lite_database.execute("select authtoken from systemaccess")
  #      return if rows.count > 0
  #      toke = SecureRandom.hex(128)
  #      sql_lite_database.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid,guid)
  #                            VALUES (?, ?, ?, ?, ?, ?)", ['admin', 'EnginesDemo', '', toke.to_s, 1, 0])
  #      STDERR.puts('init db')
  #    rescue StandardError => e
  #      STDERR.puts('init db error ' + e.to_s)
  #      return
  #    end
  #
  #
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

  def init_system_password(password, email, token = nil)
    SystemDebug.debug(SystemDebug.first_run,:applyin, password, email)
    set_system_user_password('admin', password, email, token)
    SystemDebug.debug(SystemDebug.first_run,:applied, password, email)
    
  end

  def set_system_user_password(user, password, email, token)
    rws = auth_database.execute("Select authtoken from systemaccess where  username = '" + user.to_s + "';")
    authtoken = SecureRandom.hex(64)
    if rws.nil? || rws.count == 0      
      query = 'INSERT INTO systemaccess (username, password, email, authtoken, uid)
                 VALUES (?, ?, ?, ?, ?)'
    SystemDebug.debug(SystemDebug.first_run,:applyin,  query, [user, password, email.to_s, authtoken, 0])
      auth_database.execute(query, [user, password, email.to_s, authtoken, 0])
      update_local_token(authtoken) if user == 'admin'
    else
      #authtoken = SecureRandom.hex(128)
      token = rws[0][0] if token.nil? # FIXMe should be if first run?
      raise EnginesException.new(
      level: :error,
      params: nil,
      status: nil,
      system: 'user auth',
      error_mesg: 'token missmatch') if token != rws[0][0]

      query = "UPDATE systemaccess SET password = '"\
      + password.to_s + "',email='" + email.to_s + \
      ", authtoken ='" + token.to_s + "' " + \
      " where username = '" + user + "' and authtoken = '" + authtoken.to_s + "';"
      SystemDebug.debug(SystemDebug.first_run,:applyin,  query)
      auth_database.execute(query)
      update_local_token(authtoken) if user == 'admin'
    end

  rescue StandardError => e
SystemDebug.debug(SystemDebug.first_run,"Exception " ,e)
    log_error_mesg(e.to_s)
    auth_database.close
    true
  end

  def update_local_token(token)
    toke_file = File.new('/home/engines/.engines_token' + 'w+')
    toke_file.puts(token)
    toke_file.close
  end
    
end