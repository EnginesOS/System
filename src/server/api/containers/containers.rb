# @!group /containers
NOOP_PERIOD=20
# @method get_container_event_stream
# @overload get '/v0/containers/events/stream'
# Add listener to container events and write event-stream of events as json to client
# @return [text/event-stream]
# stream is in the format
#  Do not use the "from" key
# test FixME there is none
get '/v0/containers/events/stream', provides: 'text/event-stream' do
  @lock_timer = false
  def finialise_events_stream(events_stream, timer)
    events_stream.stop unless events_stream.nil?
    timer.cancel unless timer.nil?
    EventMachine.stop
    false
  end

  def no_oploop_timer(out)
    require '/opt/engines/src/server/keep_alive_nooper.rb'
    timer = KeepAliveNooper.new
    timer.run(out)
    timer
  end

  def no_op_timer(out)
    no_op = {no_op: true}.to_json
    require 'eventmachine'
    timer = EventMachine::PeriodicTimer.new(NOOP_PERIOD) do
      if out.closed?
        STDERR.puts('NOOP found OUT IS CLOSED: ' + timer.to_s)
        timer.cancel
      else  
        EM.defer { out << "#{no_op}\n" }             
#      elsif @lock_timer.is_a?(FalseClass)
#        out << no_op + "\n"
#        elsif @lock_timer == true
#        STDERR.puts('NOOP found timer locked')
      end
    end
    timer
  end
require 'eventmachine'
EventMachine.run do

    begin

      timer = nil

      begin
        stream :keep_open do | out |
          begin
            has_data = true
            timer = no_op_timer(out)
            events_stream = engines_api.container_events_stream
            out.callback{ finialise_events_stream(events_stream, timer) }
            while has_data == true
              begin
                #    @lock_timer = false
                bytes = events_stream.rd.read_nonblock(8192)
                #      @lock_timer = true
                next if bytes.nil?
                if out.closed?
                  has_data = finialise_events_stream(events_stream, timer)
                  STDERR.puts('OUT IS CLOSED but have ' + jason_event.to_s)
                  next
                else
                   STDERR.puts(" Stream Bytes #{bytes.length}")
                  EM.defer { out << bytes unless bytes.nil? }
                  bytes = ''
                end
              rescue  Errno::ECONNRESET
                finialise_events_stream(events_stream, timer)
              rescue IO::WaitReadable
                STDERR.puts('Waiting on events stream')
                IO.select([events_stream.rd])
                retry
              rescue IOError
                has_data = finialise_events_stream(events_stream, timer)
                STDERR.puts('IORError on events stream')
                next
              end
            end
            finialise_events_stream(events_stream, timer)
          rescue StandardError => e
            STDERR.puts('EVENTS Exception' + e.to_s + ':' + e.class.name + e.backtrace.to_s)
            finialise_events_stream(events_stream, timer)
          end
        end
        timer.cancel unless timer.nil?
      rescue StandardError => e
        STDERR.puts('Stream EVENTS Exception' + e.to_s + e.backtrace.to_s)
        timer.cancel unless timer.nil?
      end
    rescue StandardError => e
      send_encoded_exception(request: request, exception: e)
    end
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
# test cd /opt/engines/tests/engines_api/containers ; make check_and_act
get '/v0/containers/check_and_act' do
  begin
    return_json(engines_api.containers_check_and_act)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
