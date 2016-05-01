
module EnginesServiceManagerErrors
  require_relative 'engines_service_manager_error.rb'
def log_warn_mesg(mesg,*objs)
  return EnginesServiceManagerError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesServiceManagerError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesServiceManagerError.new(e.to_s,:exception)
  end
end