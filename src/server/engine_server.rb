require '/opt/engines/lib/ruby/system/engines_error.rb'

begin
  require 'sinatra'
  require 'sinatra/cross_origin'
  require 'sinatra/streaming'
  require 'yajl'
  require 'ffi_yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  # require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'

  require '/opt/engines/lib/ruby/first_run_wizard/first_run_wizard.rb'

  require 'objspace'
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'

  ObjectSpace.trace_object_allocations_start

  @events_stream = nil

  STDERR.puts('++++++')
  require 'timers'
  @timers = Timers::Group.new
  @@last_error = ''

  require 'warden'
  require_relative 'warden/warden_config.rb'
  require_relative 'warden/warden_strategies.rb'

  before do
    pass if request.path == '/v0/system/uadmin/dn_lookup'
    pass if request.path == '/v0/system/login'
    pass if request.path.start_with?('/v0/unauthenticated')
    pass if request.path.start_with?('/v0/cron/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/cron/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/backup/') && source_is_service?(request, 'backup')
    pass if request.path.start_with?('/v0/restore/') && source_is_service?(request, 'backup')
    pass if request.path.start_with?('/v0/system/do_first_run') && FirstRunWizard.required?
    if request.path.start_with?('/v0/system/uadmin')
      env['warden'].authenticate!(:user_access_token)
    elsif  request.path == '/v0/containers/engines/status'
      env['warden'].authenticate!(:user_access_token) # was:admin_user_access_token
    elsif request.path.match(/\/v0\/containers\/engine\/[a-zA-Z0-9].*\/icon_url/) \
    ||  request.path.match(/\/v0\/containers\/engine\/[a-zA-Z0-9].*\/websites/)  \
    ||  request.path.match(/\/v0\/containers\/engine\/[a-zA-Z0-9].*\/status/)  \
    ||  request.path.match(/\/v0\/containers\/engine\/[a-zA-Z0-9].*\/blueprint/)
      env['warden'].authenticate!(:user_access_token)
    else
      env['warden'].authenticate!(:api_access_token)
    end
  end

  class AuthFailureApp
    def call(env)
      env['warden'].custom_failure!
      [403,{"Content-Type"=>"text/plain",  "Content-Length"=>"13", "Server"=>"thin","Error-Message" => "Invalid Token"},['Invalid Token']]
    end
  end

  FileUtils.touch('/home/engines/run/flags/startup_complete')
  sf = File.new('/home/engines/run/flags/state','w')
  begin
    sf.puts('/home/engines/run/flags/state')
  ensure
    sf.close
  end

  class Application < Sinatra::Base
    @events_s = nil
    #  set :sessions, true
    set :logging, true
    set :run, true
    set :timeout, 260
    configure do
      enable :cross_origin
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

  def engines_api
    @engines_api ||= PublicApi.instance
  end
end
