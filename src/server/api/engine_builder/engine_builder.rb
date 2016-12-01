# @!group /engine_builder/
#
# @method get_builder_status
# @overload get '/v0/engine_builder/status'
# Return builder status as Json
# @return [Hash]  :is_building :did_build_fail
get '/v0/engine_builder/status' do
  r = engines_api.build_status

  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end

# @method get_current_build_params
# @overload get '/v0/engine_builder/params'
# Return current build params
# @return  [Hash]  :engine_name :memory :repository_url :variables :reinstall :web_port :host_name  :domain_name :attached_services
get '/v0/engine_builder/params' do
  r = engines_api.current_build_params
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end

# @method get_last_build_log
# @overload get '/v0/engine_builder/last_build/log'
# Return last build log as String
# @return [String] last build log
get '/v0/engine_builder/last_build/log' do
  r = engines_api.last_build_log
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end
# @method get_last_build_param
# @overload get '/v0/engine_builder/last_build/params'
# Return the last build  params as json
# @return  [Hash]  :engine_name :memory :repository_url :variables :reinstall :web_port :host_name  :domain_name :attached_services
get '/v0/engine_builder/last_build/params' do
  r = engines_api.last_build_params
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end
# @method follow_build
# @overload get '/v0/engine_builder/follow_stream'
# Follow the current build
# @return  [text/event-stream]
get '/v0/engine_builder/follow_stream', provides: 'text/event-stream'  do
  build_log_file =  File.new(SystemConfig.BuildOutputFile, 'r')
  has_data = true
  stream :keep_open do |out|

    while has_data == true
      begin
        bytes = build_log_file.read_nonblock(1000)
        bytes.force_encoding(Encoding::UTF_8) unless bytes.nil?
        out << bytes
        bytes = ''
      rescue IO::WaitReadable
        out << bytes
        bytes = ''
        retry
      rescue EOFError
        unless out.closed?
          bytes.force_encoding(Encoding::UTF_8) unless bytes.nil?
          out  << bytes
          out  << '.'
          bytes = ''
          sleep 2
          retry if File.exist?()
          out.close
        end
        build_log_file.close
        has_data = false
      rescue IOError
        has_data = false
        out  << bytes  unless out.closed?
        build_log_file.close
        out.close unless out.closed?
      end
    end
  end

end
# @!endgroup