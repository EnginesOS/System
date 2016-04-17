require '/opt/engines/lib/ruby/system/errors_api.rb'
class EngineServer < ErrorsApi
  
  require 'sinatra'
  require 'yajl'
  
  require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
  require '/opt/engines/lib/ruby/api/system/system_status.rb'

  @@core_api = EnginesCore.new
  
  require_relative 'api/routes.rb'
  
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
    p 
    status(404)
  end
  
rescue StandardError => e
  log_error(e)
  p e
  p e.backtrace.to_s
  status(501)
    
end