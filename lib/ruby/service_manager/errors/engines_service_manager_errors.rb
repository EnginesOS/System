module EnginesServiceManagerErrors
  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  require_relative 'engines_service_manager_error.rb'

  def log_warn_mesg(mesg, *objs)
    EnginesServiceManagerError.new(mesg.to_s, :warning)
  end

  def log_error_mesg(mesg, *objs)
    super
    EnginesServiceManagerError.new(mesg.to_s, :failure)
  end

  def log_exception(e, *objs)
    super
    EnginesServiceManagerError.new(e.to_s, :exception)
  end

  def handle_exception(e)
    unless e.is_a?(RegistryException)
      log_exception(e)
    else
      STDERR.puts(' Error Level ' + e.level.to_s)
      log_exception(e) unless e.level == :warning  || e.level == :error
    end
  end

  def error_hash(mesg, params = nil)
    r = error_type_hash(mesg, params)
    r[:error_type] = :error
    r
  end

  def warning_hash(mesg, params = nil)
    r = error_type_hash(mesg, params)
    r[:error_type] = :warning
    r
  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :engines_core,
      params: params }
  end
end