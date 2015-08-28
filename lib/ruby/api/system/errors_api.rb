# @All class that report errors children of this
class ErrorsApi
  attr_reader :last_error
  @last_error = ''

  def log_error_mesg(msg, object)
    caller = caller_locations(1,1)[0].label
    @last_error = @last_error.to_s + ':' +  caller.to_s + ":" + msg.to_s + ':' + object.to_s.slice(0, 256)
    SystemUtils.log_error_mesg(msg, object)
  end

  def clear_error
    @last_error = ''
  end

  def log_exception(e)
    @last_error = e.to_s + e.backtrace.to_s
    SystemUtils.log_exception(e)
  end
end
