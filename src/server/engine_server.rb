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
  
  require 'warden'
  #require_relative 'warden/warden_config.rb'
  require_relative 'warden/warden_strategies.rb'

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
  def unauthenticated
     STDERR.puts('Server Strat unauth')
   end
  class FailureApp
   
    def call(env)
      STDERR.puts 'failure: ' + env['REQUEST_METHOD'] + ' ' + env['REQUEST_URI']
      env['warden'].custom_failure!
      STDERR.puts('env[‘PATH_INFO’] ' + env['PATH_INFO'].to_s)
    #  env['warden'].custom
    #  [302, {'Location' => '/v0/unauthenticated'},'']
      #[403,{"Error-Message" => "invalid token"} ,{"Error-Message" => "invalid token"}.to_json ] #'{"Error-Message" => "invalid token"}']
      [403,{"Content-Type"=>"text/plain",  "Content-Length"=>"12", "Server"=>"thin","Error-Message" => "Invalid Token"},['Invalid Token']]
  end
end
  class Application < Sinatra::Base
    @events_s = nil
    set :sessions, true
    set :logging, true
    set :run, true
    
    require_relative 'helpers/helpers.rb'
    require_relative 'api/routes.rb'
  rescue StandardError => e
    p e
    r = EnginesError.new('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
    STDERR.puts('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s )
    r.to_json
  end
def unauthenticated
   STDERR.puts('Sinatra Strat unauth')
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
