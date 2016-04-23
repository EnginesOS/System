begin
  require 'sinatra'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/api/public/engines_api/engines_api.rb'
  
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'

  require_relative 'utils.rb'

  set :sessions, true
  set :logging, true
  set :run, true

 core_api = EnginesCore.new
 @@engines_api = PlublicApi.new(core_api)
 
  
  @@last_error =''
  require_relative 'api/routes.rb'
  
  get '/v0/*' do
    p :No_Such_GET
    p :params
    status(404)
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

  def log_error(request, *args)
    p :ERROR
    p args
    error_mesg = {}
    error_mesg[:route] = request.fullpath
    error_mesg[:mesg] = args[0] unless args.count == 0
    error_mesg[:args] = args.to_s unless args.count == 0
    error_mesg[:api_error] =  @@engines_api.last_error.to_s
    error_mesg[:last_error] =  @@last_error.to_s
    
    
    STDERR.puts args.to_s + '::' + @@engines_api.last_error.to_s
  #  body args.to_s + ':' + @@engines_api.last_error.to_s
    status(404)
    return error_mesg.to_json
  end

  def get_engine(engine_name)
    eng = @@engines_api.loadManagedEngine(engine_name)
    return eng if eng.is_a?(ManagedEngine)
    log_error('Load failed !!!' + engine_name)
    return false
  end

  def get_service(service_name)
    service = @@engines_api.loadManagedService(service_name)
    return service if service.is_a?(ManagedService)
    log_error('Load failed !!!' + service_name)
    return false
  end
rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)

end