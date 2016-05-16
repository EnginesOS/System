begin
  require 'sinatra'
  require 'json'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'
  
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  require 'warden'

  
  require_relative 'utils.rb'
  class Application < Sinatra::Base
   
  register Sinatra::Warden
  
  set :sessions, true
  set :logging, true
  set :run, true

  end
 #unless @@engines_api
   core_api = EnginesCore.new   
       @@engines_api = PublicApi.new(core_api)
# end
       
  STDERR.puts('CREATED ENGINES API +++++++++++++++++++++++++++++++++++++++++++')
  ObjectSpace.trace_object_allocations_start
  @@last_error =''
  
   
  require_relative 'api/routes.rb'
  
  helpers do
  def engines_api
#    unless @@engines_api
#    core_api = EnginesCore.new   
#    @engines_api = PublicApi.new(core_api)
#    STDERR.puts('CREATED ENGINES API +++++++++++++++++++++++++++++++++++++++++++')
#    end
#    STDERR.puts('API SIZE ' + ObjectSpace.memsize_of(@@engines_api).to_s)
#    total = 0
#    
#    ObjectSpace.reachable_objects_from(@@engines_api).each do |obj|
#      total += ObjectSpace.memsize_of(obj)
#    end
#    STDERR.puts('API TOTAL SIZE:' +  total.to_s)
    return @@engines_api
    
  end

  def log_exception(e, *args)
    e_str = e.to_s()
    e.backtrace.each do |bt|
      e_str += bt + ' \n'
    end
    e_str += ':' + args.to_s  
    @@last_error = e_str.to_s
    STDERR.puts e_str
    
    SystemUtils.log_output(e_str, 10)
    f = File.open('/tmp/exceptions.' + Process.pid.to_s, 'a+')
    f.puts(e_str)
    f.close
    return false
  end

  def log_error(request, error_object, *args)
    p :ERROR
    p args
    error_mesg = {}
      if request.is_a?(String)
        error_mesg[:route] = request
      else        
        error_mesg[:route] = request.fullpath        
      end
    error_mesg[:error_object] = error_object
    error_mesg[:mesg] = args[0] unless args.count == 0
    error_mesg[:args] = args.to_s unless args.count == 0

    STDERR.puts args.to_s + '::' + engines_api.last_error.to_s
  #  body args.to_s + ':' + engines_api.last_error.to_s
    status(404)
    return error_mesg.to_json
  end

  def get_engine(engine_name)
    eng = engines_api.loadManagedEngine(engine_name)
#    return eng if eng.is_a?(ManagedEngine)
#    log_error('Load failed !!!' + engine_name)

    return eng
  end

  
  def get_service(service_name)

    service = engines_api.loadManagedService(service_name)
#    return service if service.is_a?(ManagedService)
#    log_error('Load failed !!!' + service_name)
   
    return service
  end

#content_type :json

  end

#  use Warden::Manager do |config|
#      config.scope_defaults :default,
#      # Set your authorization strategy
#      strategies: [:access_token],
#      # Route to redirect to when warden.authenticate! returns a false answer.
#      action: '/unauthenticated'
#      config.failure_app = self
#  end
#  
#  Warden::Manager.before_failure do |env,opts|
#      env['REQUEST_METHOD'] = 'POST'
#  end
#  
#  # Implement your Warden stratagey to validate and authorize the access_token.
#  Warden::Strategies.add(:access_token) do
#      def valid?
#          # Validate that the access token is properly formatted.
#          # Currently only checks that it's actually a string.
#          request.env["HTTP_ACCESS_TOKEN"].is_a?(String)
#      end
#  
#      def authenticate!
#          # Authorize request if HTTP_ACCESS_TOKEN matches 'youhavenoprivacyandnosecrets'
#          # Your actual access token should be generated using one of the several great libraries
#          # for this purpose and stored in a database, this is just to show how Warden should be
#          # set up.
#          access_granted = (request.env["HTTP_ACCESS_TOKEN"] == 'test_token')
#          !access_granted ? fail!("Could not log in") : success!(access_granted)
#      end
#  end



rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)

end
