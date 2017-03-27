# @!group /engine_builder/
#
# @method get_builder_status
# @overload get '/v0/engine_builder/status'
# Return builder status as Json
# @return [Hash]  :is_building :did_build_fail
get '/v0/engine_builder/status' do
  begin
    return_json(engines_api.build_status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_current_build_params
# @overload get '/v0/engine_builder/params'
# Return current build params
# @return  [Hash]  :engine_name :memory :repository_url :variables :reinstall :web_port :host_name  :domain_name :attached_services
get '/v0/engine_builder/params' do
  begin
    return_json(engines_api.current_build_params)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_last_build_log
# @overload get '/v0/engine_builder/last_build/log'
# Return last build log as String
# @return [String] last build log
get '/v0/engine_builder/last_build/log' do
  begin
    return_text(engines_api.last_build_log)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_last_build_param
# @overload get '/v0/engine_builder/last_build/params'
# Return the last build  params as json
# @return  [Hash]  :engine_name :memory :repository_url :variables :reinstall :web_port :host_name  :domain_name :attached_services
get '/v0/engine_builder/last_build/params' do
  begin
    return_json(engines_api.last_build_params)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method follow_build
# @overload get '/v0/engine_builder/follow_stream'
# Follow the current build
# @return  [text/event-stream]
get '/v0/engine_builder/follow_stream', provides: 'text/event-stream'  do
  begin
    build_log_file = File.new(SystemConfig.BuildOutputFile, 'r')
    has_data = true
    build_over = false
    stream :keep_open do |out|
      while has_data == true
        begin
          bytes = build_log_file.read_nonblock(1000)
          bytes.encode(Encoding::UTF_8) unless bytes.nil?
          out << bytes
          bytes = ''
        rescue IO::WaitReadable
          out << bytes
          bytes = ''
          IO.select([build_log_file])
          retry
        rescue EOFError
          unless out.closed?
            bytes.encode(Encoding::UTF_8) unless bytes.nil?
            out  << bytes
            out  << '.'
            bytes = ''
            sleep 2
            retry if File.exist?(SystemConfig.BuildRunningParamsFile)
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
          out << bytes  unless out.closed?
          build_log_file.close
          out.close unless out.closed?
        end
      end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
