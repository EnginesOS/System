require_relative 'engines_public_api_error.rb'

class PublicApi 
  def log_warn_mesg(mesg,*objs)
    EnginesPublicApiError.new(mesg.to_s,:warning)
  end

  def log_error_mesg(mesg,*objs)
    super
    EnginesPublicApiError.new(mesg.to_s,:failure)
  end

  def log_exception(e, *objs)
    super
    STDERR.puts("#{e.backtrace}")
    EnginesPublicApiError.new(e.to_s,:exception)
  end
  
  def handle_exception(e)
  #  return log_exception(e) unless e.is_a?(RegistryException)
    STDERR.puts(' Error  ' + e.to_s)
    #return if e.level == :warning  ||  e.level == :error
    log_exception(e)
  end
end