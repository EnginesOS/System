require 'gctools/oobgc'

begin

  require 'sinatra'
  require "sinatra/streaming"
  require 'json'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
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

  require_relative 'utils.rb'

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
    content_type 'application/json' unless  request.path.end_with?('stream')
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
    return false if service.is_a?(EnginesError)
    return true if request.ip.to_s == service.get_ip_str
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
    return false
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
  helpers do
    def engines_api
      $engines_api
    end
   
    def json_parser
     # @json_parser = Yajl::Parser.new(:symbolize_keys => true) if @json_parser.nil?
      @json_parser = FFI_Yajl::Parser.new({:symbolize_keys => true}) if @json_parser.nil?
      @json_parser
    end
    
    def empty_array
      @empty_array |= [].to_json
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
      # return EnginesError.new(msg.to_s,:error)
      code = 404
      error_mesg = {}
      if request.is_a?(String)
        error_mesg[:route] = request
      else
        error_mesg[:route] = request.fullpath
      end
      error_mesg[:error_object] = error_object
      error_mesg[:mesg] = args[0] unless args.count == 0
      error_mesg[:args] = args.to_s unless args.count == 0
      code = args[args.count-1] if args[args.count-1].is_a?(Fixnum)

      STDERR.puts args.to_s + '::' + engines_api.last_error.to_s
      #  body args.to_s + ':' + engines_api.last_error.to_s
      if error_mesg[:mesg] == 'unauthorised'
        status(403)
      else
        status(code)
      end
      return error_mesg.to_json
    end

    def get_engine(engine_name)
      eng = engines_api.loadManagedEngine(engine_name)
      # STDERR.puts("engine class " + eng.class.name + ':' + eng.to_json.to_s)
      return eng # if eng.is_a?(ManagedEngine)
      #    log_error('Load failed !!!', eng, eng.class.name, engine_name)

      #    return eng
    end

    def get_service(service_name)

      service = engines_api.loadManagedService(service_name)
      return service if service.is_a?(ManagedService) || service.is_a?(EnginesError)
      return log_error('Load Service failed !!!' + service_name, service)
    end

    def  downcase_keys(hash)
      return hash unless hash.is_a? Hash
      hash.map{|k,v| [k.downcase, downcase_keys(v)] }.to_h
    end

    require_relative 'api/routes.rb'

    def managed_containers_to_json(containers)
      if containers.is_a?(Array)
        res = []
        containers.each do |container|
          res.push(managed_container_as_json(container))
        end
        return res.to_json
      end
      return managed_container_as_json(containers)
    end

    def managed_container_as_json(container)
      container.to_h.to_json
    end


    use Warden::Manager do |config|
      config.scope_defaults :default,
      # Set your authorization strategy
      strategies: [:access_token],
      # Route to redirect to when warden.authenticate! returns a false answer.
      action: '/v0/unauthenticated'
      config.failure_app = self
    end

    Warden::Manager.before_failure do |env,opts|
      env['REQUEST_METHOD'] = 'POST'
    end

    # Implement your Warden stratagey to validate and authorize the access_token.
    Warden::Strategies.add(:access_token) do
      def valid?
        # Validate that the access token is properly formatted.
        # Currently only checks that it's actually a string.
        request.env["HTTP_ACCESS_TOKEN"].is_a?(String) | params['access_token'].is_a?(String)
      end

      def is_token_valid?(token, ip =nil)
        $engines_api.is_token_valid?(token, ip =nil)
      end

      def authenticate!
        # Authorize request if HTTP_ACCESS_TOKEN matches 'youhavenoprivacyandnosecrets'
        # Your actual access token should be generated using one of the several great libraries
        # for this purpose and stored in a database, this is just to show how Warden should be
        # set up.

        STDERR.puts("NO HTTP_ACCESS_TOKEN in header ") if request.env["HTTP_ACCESS_TOKEN"].nil?
        access_granted = is_token_valid?(request.env["HTTP_ACCESS_TOKEN"]) # == $token
        !access_granted ? fail!('Could not log in') : success!(access_granted)
      end
    end

  end

  def post_params(request)
  #  json_parser.parse(request.env["rack.input"].read)
    SystemUtils.deal_with_jason(JSON.parse(request.env["rack.input"].read, :create_additons => true ))
  rescue StandardError => e
    log_error(request, e, e.backtrace.to_s)
    {}
  end

rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)
  r = EnginesError.new('Unhandled Exception'+ e.to_s + '\n' + e.backtrace.to_s, :error, 'api')
  # status(404)
  r.to_json

end
