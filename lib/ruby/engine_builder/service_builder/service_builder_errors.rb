require_relative 'service_builder_error.rb'
module ServiceBuilderErrors

def log_warn_mesg(mesg,*objs)
  return ServiceBuilderError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    @last_error = mesg
    super
    return ServiceBuilderError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return ServiceBuilderError.new(e.to_s,:exception)
  end
  end