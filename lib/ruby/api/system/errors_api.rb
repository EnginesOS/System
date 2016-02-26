# @All class that report errors children of this
class ErrorsApi
  attr_reader :last_error
  @last_error = ''
  @debug = false
  def log_error_mesg(msg, object)
    @last_error = @last_error.to_s  + ':' + msg.to_s + ':' + object.to_s.slice(0, 256)
    msg.to_s += caller_locations(1,3) if @debug
    SystemUtils.log_error_mesg(msg, object)
  end

  def clear_error
    @last_error = ''
  end

  def log_exception(*args)
    e = args[0]
    @last_error = e.to_s + e.backtrace.to_s
    mesg = ''
    args.each do |arg|
      mesg += arg.to_s + ' '
    end
  mesg += e.backtrace.to_s
    SystemUtils.log_error_mesg(mesg)
  end
end
