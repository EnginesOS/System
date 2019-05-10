module SystemExceptions
  def SystemUtils.log_exception(*args)
    e = args[0]
    e_str = '  BT'
    e.backtrace.each do |bt|
      e_str += bt + " \n"
    end

    args.each do |arg|
      e_str += arg.to_s + ' '
    end
    @@last_error = e_str
    SystemUtils.log_output(e_str, 10)
    e_str +="\n\n"
    elof = File.open("/tmp/exceptions.log", "a+")
    begin
      elof.write(e_str)
    ensure
      elof.close
    end
    SystemUtils.log_exception_to_bugcatcher(e) unless File.exists?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    EnginesError.new(e_str.to_s, :exception)
  end

  def SystemUtils.log_exception_to_bugcatcher(e)
    require "net/http"
    require "uri"
    SystemDebug.debug(SystemDebug.system, :bug_catcher, e, e.backtrace)
    res = SystemUtils.execute_command('hostname')
    hostname = res[:stdout]
    error_log_hash = {}
    error_log_hash[:message] = e.to_s
    e_str = e.to_s
    e.backtrace.each do |bt|
      e_str += bt + " \n"
    end
    error_log_hash[:backtrace] = e_str
    # error_log_hash[:request_params] = hostname
    error_log_hash[:return_url] = 'system'
    error_log_hash[:user_comment] = ''
    error_log_hash[:user_email] = 'backend@engines.onl'
    STDERR.puts('BUG LOGGER is a ' + ENV['BUG_REPORTS_SERVER'])
    uri = URI.parse(ENV['BUG_REPORTS_SERVER'])
    conn = nil
    Net::HTTP.start(uri.host, uri.port) do |http|
      conn = http
      request = Net::HTTP.post_form(uri, error_log_hash)
      response = http.request request # Net::HTTPResponse object
      STDERR.puts('BUG LOGGER RESPONSE ' + resposnse.to_s)
      http.finish
    end
    true
  rescue
    false
  ensure
    conn.finish unless conn.nil?
  end

end