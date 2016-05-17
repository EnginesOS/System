module ContainersAPI

# @method get_container_event_strean
# @overload get /v0/containers/events/stream
# Add listener to container events and write event-stream of events as json to client 
# @return [text/event-stream]

get '/v0/containers/events/stream', provides: 'text/event-stream' do

  stream :keep_open do |out|

    @events_stream = engines_api.container_events_stream
    has_data = true

    parser = Yajl::Parser.new
   # timer =  EventMachine::PeriodicTimer.new(20) { out << "\0" }
      
    while has_data == true
      begin
        require "timeout"
        timer =  EventMachine::PeriodicTimer.new(20) { out << "\0" }
        bytes = @events_stream.rd.read_nonblock(2048)
        timer.cancel
        # jason_event = parser.parse(bytes)
        begin
          jason_event = JSON.parse(bytes)
        rescue  JSON::ParserError => e
          STDERR.puts('Failed to parse ' + bytes )
          next
        end
        #out <<'data:'
        out << jason_event.to_json
        out << "\n\n"
        STDERR.puts('EVENTS ' + jason_event.to_s + ' ' + jason_event.class.name)
        bytes = ''
      rescue IO::WaitReadable
        sleep 0.21
        retry
      rescue EOFError
        sleep 0.12
        retry
      rescue IOError
        has_data = false
        @events_stream.stop unless @events_stream.nil?
      end
    end
    timer.cancel
    @events_stream.stop unless @events_stream.nil?
  end
end
  end
