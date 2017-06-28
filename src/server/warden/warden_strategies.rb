#require 'warden'
require 'warden'
#Warden::Manager.before_failure do |env,opts|
#   # Sinatra is very sensitive to the request method
#   # since authentication could fail on any type of method, we need
#   # to set it for the failure app so it is routed to the correct block
#   puts "============== #{opts.inspect}"
#   env['REQUEST_METHOD'] = "POST"
#end

# Implement Warden stratagey to validate and authorize the access_token.
Warden::Strategies.add(:access_token) do
  def valid?
    STDERR.puts('Valid ' + token.to_s)
    request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
  end

  def is_token_valid?(token, ip = nil)
    STDERR.puts('token ' + token.to_s)
    unless token.nil?      
      $engines_api.is_token_valid?(token, ip)
    else
      false
    end
  end

  def failed
    #  status(401)
    #   send_encoded_exception(request: request, exception: 'unauthorised', params: params)
    #    STDERR.puts('FAILED ')
    fail!(action: '/v0/unauthenticated', message: 'Could not log in')
    # STDERR.puts('FAILED ')
    # warden.custom_failure!
    # send_encoded_exception(request: request, exception: 'unauthorised', params: params)
    redirect! '/v0/unauthenticated'
    #  def failure
    # warden.custom_failure!
    # render :json => {:success => false, :errors => ["Login Failed"]}
    #   end
     # throw(:warden)
  end

  def authenticate!
    STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
    access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
    # !access_granted ? fail!('Could not log in') : success!(access_granted)
     !access_granted ? failed : success!(access_granted)
  end
end