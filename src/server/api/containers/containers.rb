# @!group /containers

# @method get_container_event_stream
# @overload get '/v0/containers/events/stream'
# Add listener to container events and write event-stream of events as json to client
# @return [text/event-stream]
# stream is in the format
# {"state":"stopped",status":"stop","id":"50ffafcef4018242dcf8a89155dcf61f069b4933e69ad62c5397c9b77b2b0b22","from":"prosody","time":1463529792,"timeNano":1463529792881164857,"Type":"container","container_type":"container","container_name":"prosody"
#  Do not use the "from" key
get '/v0/containers/events/stream', provides: 'text/event-stream' do

  timer = nil
  begin
require "timeout"
  STDERR.puts('REQUEST TO  /v0/containers/events/stream')
  stream :keep_open do |out|
    begin
      STDERR.puts('OPEN EVENT STREAM')
    @events_stream = engines_api.container_events_stream
   
    has_data = true
    parser = Yajl::Parser.new(:symbolize_keys => true)
    lock_timer = false
    while has_data == true
      STDERR.puts('WHILE HAS DATA')
      begin
        
        timer = EventMachine::PeriodicTimer.new(10) do
          STDERR.puts('PERIOD')     
          if out.closed?
            has_data = false
            STDERR.puts('NOOP found OUT IS CLOSED')     
            timer.cancel unless timer.nil?
            @events_stream.stop unless @events_stream.nil?
            next
          else
            out << @no_op #unless lock_timer == true
          end
        end if timer.nil?

        bytes = @events_stream.rd.read_nonblock(2048)
        timer.cancel unless timer.nil?
        timer = nil
        begin
          jason_event = ''
         parser.parse(bytes.strip) do |event |
          
           jason_event = event
           #yajil baffs as  docker encloses within []
         end
         # jason_event = JSON.parse(bytes,:symbolize_keys => true)
        rescue  Yajl::ParseError => e
          STDERR.puts('Failed to parse docker events ' + bytes + ':' + e.to_s )
          next
        end
        #out <<'data:'
        if out.closed?
          has_data = false
          timer.cancel unless timer.nil?
          timer = nil
          STDERR.puts('OUT IS CLOSED 2')     
          next
        else
          STDERR.puts('OUT  EVENTS S ' + jason_event.to_json.to_s )
          # FIXME replace with with my
          lock_timer = true
          out << jason_event.to_json
          lock_timer = false
          bytes = ''
        end
      rescue IO::WaitReadable
       # sleep 0.4
        IO.select([@events_stream.rd])
        retry
      rescue EOFError =>e
        STDERR.puts('OUT IS EOF')     
          if has_data == false
        timer.cancel unless timer.nil?
           timer = nil
           @events_stream.stop unless @events_stream.nil?
           next
      end
        STDERR.puts('sleeping on EOF')
      sleep 1
        retry
      rescue IOError
        has_data = false
        timer.cancel unless timer.nil?
        timer = nil
        @events_stream.stop unless @events_stream.nil?
        STDERR.puts('OUT IS IOError  EVENTS S ' )
        next
      end
    end
    rescue StandardError => e
      STDERR.puts('EVENTS Exception' + e.to_s + e.backtrace.to_s)
    end
    timer.cancel unless timer.nil?
    timer = nil
    @events_stream.stop unless @events_stream.nil?
    STDERR.puts('CLOSED  EVENTS S ')
  end
  timer.cancel unless timer.nil?
  @events_stream.stop unless @events_stream.nil?
  @events_stream = nil
  STDERR.puts('END OF REQUEST TO  /v0/containers/events/stream ')
  timer.cancel unless timer.nil?
  timer = nil
#  @events_stream.stop unless @events_stream.nil?
  #   STDERR.puts('ENDED  EVENTS S ' )

  rescue StandardError => e
  STDERR.puts('Stream EVENTS Exception' + e.to_s + e.backtrace.to_s)
#
end
end

# @method check_and_act_on_containers
# @overload get '/v0/containers/check_and_act'
#
# checks status and if the container is not in the set state attempt to set it
# @return [Hash] container_name:Hash :container_type,:status,:error
#  container_name:Hash :container_type,:status,:error
#  :status is ok|fixed|failed
# ok - was in set state
# fixed returned to set state
# failed could not return to set state
# error set if failed

get '/v0/containers/check_and_act' do
  r = engines_api.containers_check_and_act.to_json
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  r.to_json
end

# @!endgroup