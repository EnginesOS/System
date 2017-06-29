# Implement Warden stratagey to validate and authorize the access_token.
Warden::Strategies.add(:access_token) do
  def valid?
    # STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end

  def is_token_valid?(token, ip = nil)
    $engines_api.is_token_valid?(token, ip)
  end

  def unauthenticated
    STDERR.puts('Warden Strat unauth')
  end

  def authenticate!
    access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
    !access_granted ? fail!('Could not log in') : success!(access_granted)
  end
end