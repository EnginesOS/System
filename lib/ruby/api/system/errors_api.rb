# @All class that report errors children of this
class ErrorsApi
  attr_reader :last_error
  @last_error = ''

  def log_error_mesg(msg, object)
    obj_str = object.to_s.slice(0, 256)
    @last_error = @last_error.to_s + ':' + msg + ':' + obj_str
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
