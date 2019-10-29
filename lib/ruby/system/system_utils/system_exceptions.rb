module SystemExceptions
  def SystemUtils.log_exception(*args)
    loggable=true
    e = args[0]
  STDERR.puts('Logging: ' + e.to_s + "\n" + e.backtrace.to_s)
    if e.is_a?(EnginesException)
      loggable = false unless e.level == :error
    end
    if loggable.is_a?(FalseClass)
      e_str = '  BT'
      e.backtrace.each do |bt|
        e_str += "#{bt}\n"
      end
      args.each do |arg|
        e_str += "#{arg} "
      end
      @@last_error = e_str
      SystemUtils.log_output(e_str, 10)
      e_str +="\n\n"
      begin
        elof = File.open("/tmp/exceptions.log", "a+")
        elof.write(e_str)
      ensure
        elof.close
      end
      SystemUtils.log_exception_to_bugcatcher(e) unless File.exists?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
      EnginesError.new(e_str.to_s, :exception)
    end
  end

  def SystemUtils.log_exception_to_bugcatcher(e)
    STDERR.puts('Logging: ' + e.to_s + "\n" + e.backtrace.to_s)
    require "net/http"
    require "uri"
    SystemDebug.debug(SystemDebug.system, :bug_catcher, e, e.backtrace)
    res = SystemUtils.execute_command('hostname')
    hostname = res[:stdout]
    error_log_hash = {}
    error_log_hash[:message] = e.to_s
    e_str = e.to_s
    e.backtrace.each do |bt|
    e_str += "#{bt} \n"
    end
    error_log_hash[:backtrace] = e_str
    error_log_hash[:return_url] = 'system'
    error_log_hash[:user_comment] = ''
    error_log_hash[:user_email] = 'backend@engines.onl'
    STDERR.puts('BUG LOGGER is a ' + ENV['BUG_REPORTS_SERVER'])
    url_s = ENV['BUG_REPORTS_SERVER'].sub(/https/,'http')
    uri = URI.parse(url_s)
    conn = nil
    req = Net::HTTP.post_form(uri, error_log_hash )
    Net::HTTP.start(uri.host, uri.port, {
      :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE}) do |http| #
      #  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      conn = http
      #FIX ME needs to be verified so never spoofed
      response = http.request(req) # Net::HTTPResponse object
      STDERR.puts('BUG LOGGER RESPONSE ' + resposnse.to_s)
      http.finish
    end
    true
  rescue StandardError =>e
    STDERR.puts('Exceptiion ' + e.to_s)
    STDERR.puts('backtrace ' + e.backtrace.to_s)
    false
  ensure
    conn.finish unless conn.nil?
  end

end