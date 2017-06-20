require_relative 'engines_core_error.rb'
require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'

module EnginesCoreErrors
  def log_warn_mesg(mesg,*objs)
    EnginesCoreError.new(mesg.to_s,:warning)
  end

  def log_error_mesg(mesg,*objs)
    super
    EnginesCoreError.new(mesg.to_s,:failure)
  end

  def log_exception(e,*objs)
    super
    EnginesCoreError.new(e.to_s,:exception)
  end

  def handle_exception(e)
    if e.is_a?(RegistryException)
      STDERR.puts(' Error Level ' + e.level.to_s)
      unless e.level == :warning  || e.level == :error
        log_exception(e)
      end
    else
      log_exception(e)
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