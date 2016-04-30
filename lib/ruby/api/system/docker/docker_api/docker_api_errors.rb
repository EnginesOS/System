module EnginesDockerApiErrors

def log_warn_mesg(mesg,*objs)
  return EnginesDockerApiError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesDockerApiError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesDockerApiError.new(mesg.to_s,:exception)
  end
  
end