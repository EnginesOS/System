require 'gctools/oobgc'
require '/opt/engines/lib/ruby/system/engines_error.rb'

begin

  require 'sinatra'
  require 'sinatra/streaming'
  #  require 'json'
  require 'yajl'
  require 'ffi_yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'

  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  require '/opt/engines/lib/ruby/api/system/first_run_wizard/first_run_wizard.rb'

  require 'objspace'
  require 'warden'

  class Application < Sinatra::Base
    @events_s = nil
    set :sessions, true
    set :logging, true
    set :run, true
  end

  ObjectSpace.trace_object_allocations_start
  core_api = EnginesCore.new
  @events_stream = nil
  $engines_api = PublicApi.new(core_api)
  STDERR.puts('CREATED ENGINES API +++++++++++++++++++++++++++++++++++++++++++')
  File.open('/engines/var/run/flags/startup_complete', 'w') {}
  @@last_error = ''

  before do
    pass if request.path.start_with?('/v0/system/login/')
    pass if request.path.start_with?('/v0/unauthenticated')
    pass if request.path.start_with?('/v0/cron/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/cron/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/engine/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/schedule/service/') && source_is_service?(request, 'cron')
    pass if request.path.start_with?('/v0/backup/') && source_is_service?(request, 'backup')
    pass if request.path.start_with?('/v0/system/do_first_run') && FirstRunWizard.required?
    env['warden'].authenticate!(:access_token)
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

  def sql_lite_database
    engines_api.auth_database
  rescue StandardError => e
    STDERR.puts('Exception failed to open  sql_lite_database: ' + e.to_s)
    false
  end
  begin
    require_relative 'helpers/helpers.rb'
    require_relative 'api/routes.rb'
  rescue StandardError => e
    STDERR.puts('Sinatra Error ' + e.to_s )
  end

  def post_params(request)
    r = request.env['rack.input'].read
    unless r.nil?
      json_parser.parse(r)
    else
      {}
    end
  rescue StandardError => e
    STDERR.puts(' POST Parse Error ' + e.to_s + ' on ' + r.to_s)
    {}
  end

rescue StandardError => e
  p e
  r = EnginesError.new('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
  STDERR.puts('Unhandled Exception' + e.to_s + '\n' + e.backtrace.to_s )
  r.to_json
end
