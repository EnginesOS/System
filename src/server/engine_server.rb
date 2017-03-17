require 'gctools/oobgc'

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

    #  STDERR.puts('init db')
    rows = sql_lite_database.execute <<-SQL
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
    #  STDERR.puts('init db')
    return if rows.count > 0
    #  STDERR.puts('init db')
    #      @auth_db.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid,guid)
    #                        VALUES (?, ?, ?, ?, ?, ?)", ["test", 'test', '', 'test_token_arandy',2,0])
    #    rows
    toke = SecureRandom.hex(128)

    sql_lite_database.execute("INSERT INTO systemaccess (username, password, email, authtoken, uid,guid)
                          VALUES (?, ?, ?, ?, ?, ?)", ["admin", 'EnginesDemo', '', toke.to_s ,1,0])
    STDERR.puts('init db')
    #  @auth_db.close
    #  @auth_db = nil
  rescue StandardError => e
    #@auth_db.close
    # @auth_db = nil
    # STDERR.puts('init db error ' + e.to_s)
    return
  end

  # FIXME remove this once all installs have proper auth
  init_db

  #require_relative 'utils.rb'

  class Application < Sinatra::Base
    @events_s = nil
    set :sessions, true
    set :logging, true
    set :run, true
  end
  #unless @@engines_api
  ObjectSpace.trace_object_allocations_start
  core_api = EnginesCore.new

  # end
  @events_stream = nil
  $engines_api = PublicApi.new(core_api)
  STDERR.puts('CREATED ENGINES API +++++++++++++++++++++++++++++++++++++++++++')

  @@last_error =''

  before do
    # content_type 'application/json' unless  request.path.end_with?('stream')
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

  def source_is_service?(request,service_name)

    service = get_service(service_name)
    return true if request.ip.to_s == service.get_ip_str
    false
  rescue
    false
  end

  #  def source_is_backup?(request)
  #    backup = get_service('backup')
  #    return true if request.ip.to_s == backup.get_ip_str
  #    return false
  #  end

  def sql_lite_database
    engines_api.auth_database

  rescue StandardError => e
    STDERR.puts('Exception failed to open  sql_lite_database: ' + e.to_s)
    false
  end
  #
  #  def save_curr_events_stream(events_stream )
  #           $events_s = events_stream
  #       STDERR.puts('set   ' + $events_s.class.name + ' from ' + events_stream.class.name )
  #         end
  #     def curr_events_stream
  #     #    @events_stream = engines_api.container_events_stream if @events_stream .nil?
  #       STDERR.puts('ret   ' + $events_s.class.name )
  #         $events_s
  #       end
  #
  require_relative 'helpers/helpers.rb'

  require_relative 'api/routes.rb'

  def post_params(request)
    r = request.env["rack.input"].read
    json_parser.parse(r)
    #deal_with_jason(request.env["rack.input"].read )
  rescue StandardError => e
    log_error(request, e, e.backtrace.to_s)
    STDERR.puts(' POST Parse Error ' + e.to_s + ' on ' + r.to_s )
    {}
  end

rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)
  r = EnginesError.new('Unhandled Exception'+ e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
  # status(404)
  STDERR.puts('Unhandled Exception'+ e.to_s + '\n' + e.backtrace.to_s )
  r.to_json

end
