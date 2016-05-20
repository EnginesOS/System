# @!group Containers

# @method get_container_event_stream
# @overload get '/v0/containers/events/stream'
# Add listener to container events and write event-stream of events as json to client 
# @return [text/event-stream]
# stream is in the format 
# {"status":"stop","id":"50ffafcef4018242dcf8a89155dcf61f069b4933e69ad62c5397c9b77b2b0b22","from":"prosody","time":1463529792,"timeNano":1463529792881164857,"Type":"container","container_type":"container","container_name":"prosody"
get '/v0/containers/events/stream', provides: 'text/event-stream' do

  stream :keep_open do |out|

    @events_stream = engines_api.container_events_stream
    has_data = true

    parser = Yajl::Parser.new
    timer = nil
    while has_data == true
      begin
        require "timeout"
        timer =  EventMachine::PeriodicTimer.new(5) { out << "\n" } if timer.nil?
        bytes = @events_stream.rd.read_nonblock(2048)
        timer.cancel
        timer = nil
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
        sleep 0.21
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

# @method check_and_act_on_containers
# @overload get '/v0/containers/check_and_act'
# 
# checks status and if the container is not in the set state attempt to set it
# @return [Hash]
#  container_name:{:container_type,:status,:error]
#  :status is ok|fixed|failed
# ok - was in set state
# fixed returned to set state
# failed could not return to set state
# error set if failed

get '/v0/containers/check_and_act' do
  r = engines_api.containers_check_and_act.to_json
  unless r.is_a?(EnginesError)
     return r.to_json
   else
     return log_error(request, r, engine.last_error)
   end
end

# @!endgroup