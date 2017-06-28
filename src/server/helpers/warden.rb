use Warden::Manager do |config|
   config.scope_defaults :default,
   strategies: [:access_token], # Set your authorization strategy
   action: :unauthenticated # Route to redirect to when warden.authenticate! returns a false answer.
    config.failure_app = lambda { |env| 
      STDERR.puts('Its a :AMBDA')
  failure_action = env["warden.options"][:action].to_sym
      STDERR.puts('Its a :AMBDA action ' + failure_action.to_s)
      STDERR.puts('Its a :AMBDA env' + env.to_s)
      redirect! '/v0/unauthenticated'
      #  STDERR.puts('_______' + caller.to_s)
     # redirect! '/v0/unauthenticated'
    #  STDERR.puts('_______')
    #  unauthenticated(env)
      
} #self.class
 end

 # Implement your Warden stratagey to validate and authorize the access_token.
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
    # send_encoded_exception(request: request, exception: 'unauthorised', params: params)
     # redirect! '/v0/unauthenticated'
    #  def failure        
     # warden.custom_failure!
      # render :json => {:success => false, :errors => ["Login Failed"]}
     #   end
     #throw(:warden, :action => :unauthenticated)
   end
   
   def unauthenticated(*args)
      STDERR.puts('Un authed Helper' + arg.to_s)
    end
   def authenticate!
     STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
     access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'])
    # !access_granted ? fail!(action: 'unauthenticated', message: 'Could not log in') : success!(access_granted)
    !access_granted ? failed : success!(access_granted)
   end
 end
