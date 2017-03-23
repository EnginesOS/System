require 'gctools/oobgc'
require '/opt/engines/lib/ruby/system/engines_error.rb'

begin

  require 'sinatra'
  require "sinatra/streaming"
  require 'json'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'

  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  require '/opt/engines/lib/ruby/api/system/first_run_wizard/first_run_wizard.rb'

  require 'objspace'
  require 'warden'
  require "sqlite3"
  require 'ffi_yajl'

  def init_db
    create_table
    set_first_user
  end

  def create_table
    sql_lite_database.execute <<-SQL
            create table systemaccess (
              username varchar(30),
              email varchar(128),
              password varchar(30),
              authtoken varchar(128),
              ip_addr varchar(64), 
              ip_mask varchar(64),
              uid int,
              guid int
            );
    SQL
    true
  rescue
    true
  end

  def set_first_user
    rows = sql_lite_database.execute( "select authtoken from systemaccess" )
    return if rows.count > 0
    toke = SecureRandom.hex(128)
    sql_lite_database.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid,guid)
                          VALUES (?, ?, ?, ?, ?, ?)", ["admin", 'EnginesDemo', '', toke.to_s ,1,0])
    STDERR.puts('init db')
  rescue StandardError => e
    STDERR.puts('init db error ' + e.to_s)
    return
  end

  # FIXME remove this once all installs have proper auth
  init_db

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

  @@last_error = ''

  before do
    pass if request.path.start_with?('/v0/system/login/')
    pass if request.path.start_with?('/v0/unauthenticated')
    pass if request.path.start_with?('/v0/cron/engine/')  && source_is_service?(request,'cron')
    pass if request.path.start_with?('/v0/cron/service/')  && source_is_service?(request,'cron')
    pass if request.path.start_with?('/v0/schedule/engine/')  && source_is_service?(request,'cron')
    pass if request.path.start_with?('/v0/schedule/service/')  && source_is_service?(request,'cron')
    pass if request.path.start_with?('/v0/backup/')  && source_is_service?(request,'backup')
    pass if request.path.start_with?('/v0/system/do_first_run') && FirstRunWizard.required?
    env['warden'].authenticate!(:access_token)
  end

  def source_is_service?(request, service_name)
    service = get_service(service_name)
    return true if request.ip.to_s == service.get_ip_str
    false
  rescue
    false
  end

  def sql_lite_database
    engines_api.auth_database
  rescue StandardError => e
    STDERR.puts('Exception failed to open  sql_lite_database: ' + e.to_s)
    false
  end

  require_relative 'helpers/helpers.rb'
  require_relative 'api/routes.rb'

  def post_params(request)
    r = request.env["rack.input"].read
    json_parser.parse(r)
  rescue StandardError => e
    log_error(request, e, e.backtrace.to_s)
    STDERR.puts(' POST Parse Error ' + e.to_s + ' on ' + r.to_s )
    {}
  end

rescue StandardError => e
  p e
  r = EnginesError.new('Unhandled Exception'+ e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
  STDERR.puts('Unhandled Exception'+ e.to_s + '\n' + e.backtrace.to_s )
  r.to_json
end
