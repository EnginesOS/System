use Warden::Manager do |config|
  config.scope_defaults :default,
  strategies: [:access_token], # Set your authorization strategy
  action: 'v0/unauthenticated' # Route to redirect to when warden.authenticate! returns a false answer.
    config.failure_app = lambda { |env|
      begin
      STDERR.puts('Its a :AMBDA')
     failure_action = env["warden.options"][:action].to_sym
     STDERR.puts('Its a :AMBDA action ' + failure_action.to_s)
     STDERR.puts('Its a :AMBDA env' + env.to_s)
      env['warden'].custom_failure!
      env['rack.errors'].write('Auth failed')
       
      #  redirect! '/v0/unauthenticated'
     #  STDERR.puts('_______' + caller.to_s)
    # redirect! '/v0/unauthenticated'
      STDERR.puts('_______' + self.class.name)
    #  unauthenticated(env)
    rescue StandardError => e
        STDERR.puts('_______' + e.to_s)
      end
   } 
    config.failure_app = self
end

