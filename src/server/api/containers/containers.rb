# @!group /containers

# @method get_container_event_stream
# @overload get '/v0/containers/events/stream'
# Add listener to container events and write event-stream of events as json to client
# @return [text/event-stream]
# stream is in the format
#  Do not use the "from" key
# test FixME there is none
get '/v0/containers/events/stream', provides: 'text/event-stream' do
STDERR.puts(' CGET EVE')
  begin
    def finialise_events_stream(events_stream, timer)
      events_stream.stop unless events_stream.nil?
      timer.cancel unless timer.nil?
      STDERR.puts('Finalised Event')
      false
    end

    def no_op_timer(out)
      require '/opt/engines/src/server/keep_alive_nooper.rb'
      timer = KeepAliveNooper.new
      timer.run(out)
      timer
#      
#      require 'timers'
#      no_op = {no_op: true}.to_json
#      #EventMachine::PeriodicTimer.new(25) do
#      # @timers  ||= Timers::Group.new
#    @timers = Timers::Group.new
#       @timers.after(25) do
#        if out.closed?
#          STDERR.puts('NOOP found OUT IS CLOSED: ' )          
#          timer = nil
#          next
#        else
#          out << no_op # unless lock_timer == true
#          STDERR.puts('NOOP ')
#          out << "\n"
#        end
#       end 
    end
    begin
      stream :keep_open do | out |
        begin
          STDERR.puts('Stream' )        
          has_data = true
          timer = no_op_timer(out)
          events_stream = engines_api.container_events_stream
          out.callback{ finialise_events_stream(events_stream, timer) }
          while has_data == true
            begin
              bytes = events_stream.rd.read_nonblock(2048)
              next if bytes.nil?
              if out.closed?
                has_data = finialise_events_stream(events_stream, timer)
                # STDERR.puts('OUT IS CLOSED but have ' + jason_event.to_s)
                next
              else
                out << bytes unless bytes.nil?
                bytes = ''
              end
            rescue IO::WaitReadable
              IO.select([events_stream.rd])
              retry
            rescue IOError
              has_data = finialise_events_stream(events_stream, timer)
              next
            end
          end
        rescue StandardError => e
          STDERR.puts('EVENTS Exception' + e.to_s + ':' + e.class.name + e.backtrace.to_s)
          finialise_events_stream(events_stream, timer)
        end
      end
    rescue StandardError => e
      STDERR.puts('Stream EVENTS Exception' + e.to_s + e.backtrace.to_s)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
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
