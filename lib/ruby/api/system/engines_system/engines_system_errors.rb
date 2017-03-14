
module EnginesSystemErrors
  require_relative 'engines_system_error.rb'
def log_warn_mesg(mesg,*objs)
   EnginesSystemError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)

     EnginesSystemError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
 
     EnginesSystemError.new(e.to_s + ':' + e.backtrace.to_s,:exception)
  end
end