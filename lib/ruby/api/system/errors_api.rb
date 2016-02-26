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
  SystemUtils.log_exception_to_bugcatcher(e) unless File.exists?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    @last_error = e.to_s + e.backtrace.to_s
    mesg = @last_error + ':'
    args.each do |arg|
      mesg += arg.to_s + ' '
    end

    SystemUtils.log_error_mesg(mesg)
  end
end
