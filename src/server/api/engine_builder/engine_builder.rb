

get '/v0/engine_builder/status' do
 r = engines_api.build_status

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/engine_builder/params' do
  r = engines_api.current_build_params
  unless r.is_a?(EnginesError)
     return r.to_json
   else
     return log_error(request, r)
   end
 end


get '/v0/engine_builder/last_build/log' do
  r = engines_api.last_build_log
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/engine_builder/last_build/params' do
  r = engines_api.last_build_params

  unless r.is_a?(EnginesError)
      return r.to_json
    else
      return log_error(request, r)
    end
  end
 
get '/v0/engine_builder/follow', provides: 'text/event-stream'  do
  build_log_file =  File.new(SystemConfig.BuildOutputFile, 'r')
  has_data = true
  stream :keep_open do |out|
    

  
    while has_data == true 
      begin
        bytes = build_log_file.read_nonblock(1000)            
        out << bytes     
        bytes = ''
      rescue IO::WaitReadable
        out << bytes     
        bytes = ''
        retry
      rescue EOFError
        bytes = '.' if bytes == ''
        out  << bytes
        bytes = ''
        sleep 2
        retry if File.exist?(SystemConfig.BuildRunningParamsFile)
        build_log_file.close
        has_data = false

        out.close
      rescue IOError
        has_data = false
        out  << bytes 
        build_log_file.close

        out.close
      end
    end
    
  end

end
