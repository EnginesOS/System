#
#/containers/changed LIST
#/containers/name/network_metrics  ?
#
get '/v0/containers/changed/' do
  changed = engines_api.get_changed_containers
  unless changed.is_a?(EnginesError)
    return changed.to_json
  else
    return log_error(request, changed)
  end
end
  
  get '/v0/containers/events/', provides: 'text/event-stream' do
    p :containers_events
    stream :keep_open do |out|
      stream = engines_api.container_events_stream
      has_data = true
      while has_data == true 
        begin
          bytes = stream.read_nonblock(1024)    
          jason_event = JSON.parse(bytes)        
          out << jason_event

          STDERR.puts('EVENTS ' + jason_event.to_s)     
          bytes = ''
        rescue IO::WaitReadable
          out << bytes     
          bytes = ''
          sleep 0.21
          retry
        rescue EOFError
         
          out  << bytes
          out  << '.'
          bytes = ''
          sleep 0.12
          retry

        rescue IOError
          has_data = false
          out  << bytes 
          stream.close
  
          out.close
        end
      end
    end
    
    
  end
  


