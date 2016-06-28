
module EnginesFirstRunErrors
  require_relative 'engines_first_run_error.rb'
def log_warn_mesg(mesg,*objs)
  return EnginesFirstRunError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesFirstRunError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesFirstRunError.new(e.to_s,:exception)
  end
end