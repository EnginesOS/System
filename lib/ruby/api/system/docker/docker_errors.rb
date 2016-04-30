def log_warn_mesg(mesg,*objs)
  return EnginesDockerError.new(e.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesDockerError.new(e.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesDockerError.new(e.to_s,:exception)
  end