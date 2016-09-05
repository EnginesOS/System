
module EnginesSystemErrors
  require_relative 'engines_system_error.rb'
def log_warn_mesg(mesg,*objs)
  return EnginesSystemError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)

    return EnginesSystemError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
 
    return EnginesSystemError.new(e.to_s + ':' + e.backtrace.to_s,:exception)
  end
end