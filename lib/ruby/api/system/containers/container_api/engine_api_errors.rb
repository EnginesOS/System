
module EngineApiErrors
  require_relative 'engine_api_error.rb'
def log_warn_mesg(mesg,*objs)
  return EngineApiError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EngineApiError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EngineApiError.new(e.to_s,:exception)
  end
end