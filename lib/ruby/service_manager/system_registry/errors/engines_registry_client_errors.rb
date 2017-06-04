module EnginesRegistryClientErrors
  require_relative 'engines_registry_client_error.rb'
  def log_warn_mesg(mesg, *objs)
    EnginesRegistryClientError.new(mesg.to_s, :warning)
  end

  def log_error_mesg(mesg, *objs)
    super
    EnginesRegistryClientError.new(mesg.to_s, :failure)
  end

  def log_exception(e, *objs)
    super(e)
    EnginesRegistryClientError.new(e.to_s, :exception, objs)
  end

  def error_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :registry,
      params: params }
  end
end