require_relative 'engines_core_error.rb'
module EnginesCoreErrors

def log_warn_mesg(mesg,*objs)
   EnginesCoreError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
     EnginesCoreError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
     EnginesCoreError.new(e.to_s,:exception)
  end
  
  def handle_exception(e)
    return log_exception(e) unless e.is_a?(RegistryException)
    STDERR.puts(' Error Level ' + e.level.to_s)
    return if e.level == :warning  ||  e.level == :error
    log_exception(e)
  end
  
  end