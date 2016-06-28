
module EnginesRegistryClientErrors
  require_relative 'engines_registry_client_error.rb'
def log_warn_mesg(mesg,*objs)
  return EnginesRegistryClientError.new(mesg.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesRegistryClientError.new(mesg.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super(e)
    return EnginesRegistryClientError.new(e.to_s,:exception, objs)
  end
end