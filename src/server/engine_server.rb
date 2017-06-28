require 'gctools/oobgc'
require '/opt/engines/lib/ruby/system/engines_error.rb'

begin

  require 'sinatra'
  require 'sinatra/streaming'
  require 'yajl'
  require 'ffi_yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
 # require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'

  require '/opt/engines/lib/ruby/api/system/first_run_wizard/first_run_wizard.rb'

  require 'objspace'
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  ObjectSpace.trace_object_allocations_start
  @events_stream = nil
  $engines_api = PublicApi.new(EnginesCore.new)
  STDERR.puts('++++')
  FileUtils.touch('/engines/var/run/flags/startup_complete')
  @@last_error = ''

  

  before do
    pass if request.path.start_with?('/v0/system/login')
    pass if request.path.start_with?('/v0/unauthenticated')
    pass if request.path.start_with?('/v0/cron/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/cron/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/backup/') && source_is_service?(request, 'backup')
    pass if request.path.start_with?('/v0/system/do_first_run') && FirstRunWizard.required?
    env['warden'].authenticate!(:access_token)
    
  end

  class Application < Sinatra::Base
    @events_s = nil
    set :sessions, true
    set :logging, true
    set :run, true
    require 'warden'
    #require_relative 'warden/warden_config.rb'
   # require_relative 'warden/warden_strategies.rb'
    use Warden::Manager do |config|
      # config.default_scope :default
      config.scope_defaults :default,
      strategies: [:access_token], # Set your authorization strategy
      action: '/v0/unauthenticated' # Route to redirect to when warden.authenticate! returns a false answer.
    #    config.failure_app = lambda { |env|
    #      begin
    #      STDERR.puts('Its a :AMBDA')
    #     failure_action = env["warden.options"][:action].to_sym
    #     STDERR.puts('Its a :AMBDA action ' + failure_action.to_s)
    #     STDERR.puts('Its a :AMBDA env' + env.to_s)
    #        #   env['warden'].custom_failure!
    #          env['rack.errors'].write('Auth failed')
    #       
    #      #  redirect! '/v0/unauthenticated'
    #       STDERR.puts('_______' + caller.to_s)
    #    # redirect! '/v0/unauthenticated'
    #       
    #      STDERR.puts('_______' + self.methods.to_s)
    #    #  unauthenticated(env)
    #    rescue StandardError => e
    #        STDERR.puts('_______' + e.to_s)
    #      end
    #   } 
       config.failure_app = self
    end
    Warden::Manager.before_failure do |env,opts|
       # Sinatra is very sensitive to the request method
       # since authentication could fail on any type of method, we need
       # to set it for the failure app so it is routed to the correct block
       puts "============== #{opts.inspect}"
       env['REQUEST_METHOD'] = "POST"
    end
    
    # Implement Warden stratagey to validate and authorize the access_token.
    Warden::Strategies.add(:access_token) do
      def valid?
        STDERR.puts('Valid ' + request.env['HTTP_ACCESS_TOKEN'].to_s)
        request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
      end
    
      def is_token_valid?(token, ip = nil)
        STDERR.puts('token ' + token.to_s)
          $engines_api.is_token_valid?(token, ip)
      end
    
      def failed
        #  status(401)
        #   send_encoded_exception(request: request, exception: 'unauthorised', params: params)
        #    STDERR.puts('FAILED ')
        fail!(action: '/v0/unauthenticated', message: 'Could not log in')
        # STDERR.puts('FAILED ')
        # warden.custom_failure!
        # send_encoded_exception(request: request, exception: 'unauthorised', params: params)
        #  redirect! '/v0/unauthenticated'
        #  def failure
        # warden.custom_failure!
        # render :json => {:success => false, :errors => ["Login Failed"]}
        #   end
           throw(:warden)
      end
    
      def authenticate!
        STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
        access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'], request.env['REMOTE_ADDR'])
         !access_granted ? fail!('Could not log in') : success!(access_granted)
        #  !access_granted ? failed : success!(access_granted)
      end
    end
    require_relative 'helpers/helpers.rb'
    require_relative 'api/routes.rb'
  rescue StandardError => e
    p e
    r = EnginesError.new('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
    STDERR.puts('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s )
    r.to_json
  end

  def source_is_service?(request, service_name)
    service = get_service(service_name)
    if request.ip.to_s == service.get_ip_str
      true
    else
      false
    end
  rescue
    false
  end

end
