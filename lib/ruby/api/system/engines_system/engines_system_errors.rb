require_relative 'engines_system_error.rb'

def log_warn_mesg(mesg,*objs)
  return EnginesSystemError.new(e.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesSystemError.new(e.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesSystemError.new(e.to_s,:exception)
  end