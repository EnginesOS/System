require '/opt/engines/lib/ruby/system/engines_error.rb'
# @All class that report errors children of this
class ErrorsApi
  attr_reader :last_error
  @last_error = ''
  @debug = false
  def log_error_mesg(msg, *objects)
    @last_error = msg.to_s  # + ':' + objects.to_s.slice(0, 256)
    msg.to_s += caller_locations(1,3) if @debug
    SystemUtils.log_error_mesg(msg, objects)
    return EnginesError.new(msg.to_s,:error)
  end

  def clear_error
    @last_error = ''
  end

  def log_exception(e, *args)

  SystemUtils.log_exception_to_bugcatcher(e) unless File.exists?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    @last_error = e.to_s + e.backtrace.to_s
    mesg = @last_error + ':'
    args.each do |arg|
      if arg.is_a?(Hash)
      arg = arg.to_json 
      else
        arg = arg.to_s
      end
      mesg += arg.to_s + ' '
    end
  STDERR.puts(e.to_s + e.backtrace.to_s)
    STDERR.puts(caller[1].to_s)
    SystemUtils.log_error_mesg('EXCEPTION:',mesg)
    return EnginesError.new(mesg.to_s,:exception)
  end
end
