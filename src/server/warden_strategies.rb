require 'warden'
# Implement Warden stratagey to validate and authorize the access_token.
Warden::Strategies.add(:access_token) do
  def valid?
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end

  def is_token_valid?(token, ip = nil)
    $engines_api.is_token_valid?(token, ip)
  end

  def failed
    #  status(401)
    #   send_encoded_exception(request: request, exception: 'unauthorised', params: params)
    #    STDERR.puts('FAILED ')
    fail!(action: :unauthenticated, message: 'Could not log in')
    STDERR.puts('FAILED ')
    # warden.custom_failure! 
    # send_encoded_exception(request: request, exception: 'unauthorised', params: params)
   # redirect! '/v0/unauthenticated'
    #  def failure
    # warden.custom_failure!
    # render :json => {:success => false, :errors => ["Login Failed"]}
    #   end
    throw(:warden, :action => :unauthenticated)
  end

  def unauthenticated(*args)
    STDERR.puts('Un authed Helper' + arg.to_s)
  end

  def authenticate!
    STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'])
    # !access_granted ? fail!('Could not log in') : success!(access_granted)
    !access_granted ? failed : success!(access_granted)
  end
end