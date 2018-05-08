# Implement Warden stratagey to validate and authorize the access_token.
Warden::Strategies.add(:api_access_token) do
  def valid?
    # STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end

  def is_admin_token_valid?(token, ip = nil)
    $engines_api.is_admin_token_valid?(token, ip)
  end

  def unauthenticated
    STDERR.puts('Warden Strat unauth')
  end

  def is_user_token_valid?(token, ip = nil)
    $engines_api.is_user_token_valid?(token, ip)
  end

  def authenticate!
    access_granted = is_admin_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
    !access_granted ? fail!('Not logged in') : success!(access_granted)
  end

end

Warden::Strategies.add(:admin_user_access_token) do
  def valid?
    # STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end

  def is_admin_token_valid?(token, ip = nil)
    $engines_api.is_admin_token_valid?(token, ip)
  end

  def unauthenticated
    STDERR.puts('Warden Strat unauth')
  end

  def is_user_token_valid_admin?(token, ip = nil)
    if $engines_api.is_admin_token_valid?(token, ip)
      true
    elsif $engines_api.is_user_token_valid?(token, ip)
      if get_token_user(token) == 'admin'
        true
      else
        false
      end
    else
      false
    end
  end

  def authenticate!
    access_granted = is_user_token_valid_admin?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
    !access_granted ? fail!('Not logged in') : success!(access_granted)
  end

end

# Implement Warden stratagey to validate and authorize the access_token.
Warden::Strategies.add(:user_access_token) do
  def valid?
    # STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end
  #
  #  def is_admin_token_valid?(token, ip = nil)
  #    $engines_api.is_admin_token_valid?(token, ip)
  #  end

  def unauthenticated
    STDERR.puts('Warden Strat unauth')
  end

  def is_user_token_valid?(token, ip = nil)
    $engines_api.is_user_token_valid?(token, ip)
  end

  #  def authenticate!
  #    access_granted = is_admin_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
  #    !access_granted ? fail!('Not logged in') : success!(access_granted)
  #  end

  def authenticate!
    STDERR.puts('USER Auth ' +request.env['HTTP_ACCESS_TOKEN'].to_s )
    access_granted = is_user_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
    !access_granted ? fail!('No user logged in') : success!(access_granted)
  end

end