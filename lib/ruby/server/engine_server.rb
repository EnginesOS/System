

  begin 
  require 'sinatra'
  require 'yajl'
  require '/opt/engines/lib/ruby/system/system_debug.rb'
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  
require_relative 'utils.rb'
  
  set :sessions, true
  set :logging, true
  set :run, true
   
  @@core_api = EnginesCore.new
  
  require_relative 'api/routes.rb'
  
  get '/v0/*' do
    p :No_Such_GET
    p :params
    status(404)
  end
  
  
  def log_exception(e)
    e_str = e.to_s()
    e.backtrace.each do |bt|
      e_str += bt + ' \n'
    end
    @@last_error = e_str
    STDERR.puts e_str
    SystemUtils.log_output(e_str, 10)
    f = File.open('/tmp/exceptions.' + Process.pid.to_s, 'a+')
    f.puts(e_str)
    f.close
    return false
  end
  
  def log_error(*args)
    p :ERROR
    p args
    body args.to_s + ':' + @@core_api.last_error
    status(404)
  end
  
  def get_engine(engine)
    eng = @@core_api.LoadManagedEngine(engine)
    return eng if eng.is_a?(ManagedEngine)
    log_error('Load ' + engine)
    end 
      
      
rescue StandardError => e
  #log_error(e)
  p e
  p e.backtrace.to_s
  #status(501)
    
end