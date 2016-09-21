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
require "timeout"
  stream :keep_open do |out|
    @events_stream = engines_api.container_events_stream
    has_data = true
    no_op = {:no_op => true}
    parser = Yajl::Parser.new(:symbolize_keys => true)
    lock_timer = false
    while has_data == true
      begin
        timer = EventMachine::PeriodicTimer.new(15) do
          if out.closed?
            has_data = false
            timer.cancel unless timer.nil?
            @events_stream.stop unless @events_stream.nil?
          else
            out << no_op.to_json #unless lock_timer == true
          end
        end if timer.nil?

        bytes = @events_stream.rd.read_nonblock(2048)
        timer.cancel
        timer = nil
        begin
         jason_event = parser.parse(bytes) #yajil baffs as  docker encloses within []
       
         # jason_event = JSON.parse(bytes,:symbolize_keys => true)
        rescue  Yajl::ParseError => e
          STDERR.puts('Failed to parse ' + bytes + ':' + e.to_s )
          next
        end
        #out <<'data:'
        if out.closed?
          has_data = false
        else
          lock_timer = true
          out << jason_event.to_json
          lock_timer = false
          bytes = ''
        end
      rescue IO::WaitReadable
        sleep 0.4
        retry
      rescue EOFError =>e
        sleep 0.4
        retry
      rescue IOError
        has_data = false
        timer.cancel unless timer.nil?
        timer = nil
        @events_stream.stop unless @events_stream.nil?
      end
    end
    timer.cancel unless timer.nil?
    timer = nil
    @events_stream.stop unless @events_stream.nil?
  end
  timer.cancel unless timer.nil?
  timer = nil
  @events_stream.stop unless @events_stream.nil?
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