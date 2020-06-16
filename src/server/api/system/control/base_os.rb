# @!group  /system/control/base_os/

# @method restart_base_os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return [true]
# not in auto tests
# test cd /opt/engines/tests/engines_api/system/control/base_os; make restart
get '/v0/system/control/base_os/restart' do
  begin
    return_json(engines_api.restart_base_os)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method shutdown_base_os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
# @param :reason
#  :reason
# @return [true]
# not in auto tests
# test cd /opt/engines/tests/engines_api/system/control/base_os; make shutdown
post '/v0/system/control/base_os/shutdown' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], [:reason])
    shutdown = cparams[:reason]
    return_text(engines_api.halt_base_os(shutdown))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method update_base_os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return [true|false]
# test cd /opt/engines/tests/engines_api/system/control/base_os; make update
get '/v0/system/control/base_os/update' do
  begin
    return_text(engines_api.update_base_os)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method set system timezone
# @overload get '/v0/system/control/base_os/timezone'
# set system timezone
# post param :timezone
# @return [true|false]
# test cd /opt/engines/tests/engines_api/system/control/base_os; make timezone
post '/v0/system/control/base_os/timezone' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:timezone])
    return_text(engines_api.set_timezone(cparams[:timezone]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get system timezone
# @overload get '/v0/system/control/base_os/timezone'
# get system timezone
# @return [String]
# test cd /opt/engines/tests/engines_api/system/control/base_os; make timezone
get '/v0/system/control/base_os/timezone' do
  begin
    return_text(engines_api.get_timezone())
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set system locale
# @overload get '/v0/system/control/base_os/locale'
# set system locale
# post param :locale
# @return [true|false]
# test cd /opt/engines/tests/engines_api/system/control/base_os; make locale
post '/v0/system/control/base_os/locale' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:country_code, :lang_code])
    return_text(engines_api.set_locale(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end

end
# @method get system locale
# @overload get '/v0/system/control/base_os/locale'
# set system locale
# @return [String]
# test cd /opt/engines/tests/engines_api/system/control/base_os; make locale
get '/v0/system/control/base_os/locale' do
  begin
    return_json(engines_api.get_locale())
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end

end

# @method follow_base_os_update
# @overload get '/v0/system/control/base_os/follow_update'
# Follow the run os update
# @return  [text/event-stream]
# test cd  /opt/engines/tests/  Belum
get '/v0/system/control/base_os/follow_update', provides: 'text/event-stream;charset=ascii-8bit' do
  unless File.exists?(SystemConfig.BaseOSUpdateRunningLog)
    return_json(false)
  else
  begin
    build_log_file = File.new(SystemConfig.BaseOSUpdateRunningLog, 'r')
    has_data = true
    build_over = false
    begin
    stream :keep_open do |out|
      while has_data == true
        begin
          bytes = build_log_file.read_nonblock(1000)
          bytes.encode(Encoding::ASCII_8BIT) unless bytes.nil?
          out << bytes
          bytes = ''
        rescue IO::WaitReadable
          out << bytes
          bytes = ''
          IO.select([build_log_file])
          retry
        rescue EOFError
          unless out.closed?
            bytes.encode(Encoding::ASCII_8BIT) unless bytes.nil? #UTF_8) unless bytes.nil?
            out << bytes
            out << '.'
            bytes = ''
            sleep 2
            retry if File.exist?(SystemConfig.BaseOSUpdateRunningLog)
            if build_over == false
              build_over = true
              retry
            end
            out.close
          end
          build_log_file.close
          has_data = false
        rescue IOError
          has_data = false
          out << bytes unless out.closed?
          build_log_file.close
          out.close unless out.closed?
        rescue StandardError => e
          out << bytes unless out.closed?
        end
      end
    end
  end
  
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
end
# @!endgroup
