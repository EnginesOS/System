require_relative 'engines_core_error.rb'
module EnginesCoreErrors

def log_warn_mesg(mesg,*objs)
  return EnginesCoreError.new(e.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesCoreError.new(e.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesCoreError.new(e.to_s,:exception)
  end
  end