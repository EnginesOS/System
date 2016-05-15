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

    stream :keep_open do |out|
     
      events_stream = engines_api.container_events_stream
      has_data = true
      written = false
      parser = Yajl::Parser.new
      
      while has_data == true
begin
        status = Timeout::timeout(50) do
        
         
          bytes = events_stream.rd.read_nonblock(2048)   
         # jason_event = parser.parse(bytes) 
          jason_event = JSON.parse(bytes)   
          #out <<'data:'     
          out << jason_event.to_json
          out << "\n\n"
          written = true
          STDERR.puts('EVENTS ' + jason_event.to_s + ' ' + jason_event.class.name)     
          bytes = ''
        end
        rescue IO::WaitReadable
          sleep 0.21
          retry
        rescue EOFError          
          sleep 0.12
          retry
          rescue Timeout::Error
            out << "\n\n" unless written
            written = false
            retry
        rescue IOError
          has_data = false
  events_stream.stop
        end
     
      end
      
    end
    events_stream.stop
    
  end
  


