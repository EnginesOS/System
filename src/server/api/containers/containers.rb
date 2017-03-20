# @!group /containers

# @method get_container_event_stream
# @overload get '/v0/containers/events/stream'
# Add listener to container events and write event-stream of events as json to client
# @return [text/event-stream]
# stream is in the format
# {"state":"stopped",status":"stop","id":"50ffafcef4018242dcf8a89155dcf61f069b4933e69ad62c5397c9b77b2b0b22","from":"prosody","time":1463529792,"timeNano":1463529792881164857,"Type":"container","container_type":"container","container_name":"prosody"
#  Do not use the "from" key

get '/v0/containers/events/stream', provides: 'text/event-stream' do
  begin
    def finialise_events_stream(events_stream, timer)
      #  STDERR.puts('finalise   ' + events_stream.class.name)
      events_stream.stop unless events_stream.nil?
      #   STDERR.puts('finalise  /v0/containers/events/stream ')
      timer.cancel unless timer.nil?
      return false
    end

    begin
      #   STDERR.puts('REQUEST TO  /v0/containers/events/stream')

      stream :keep_open do | out  |
        begin
          has_data = true

          timer = EventMachine::PeriodicTimer.new(25) do

            if out.closed?
              # has_data = finialise_events_stream(events_stream)
              STDERR.puts('NOOP found OUT IS CLOSED: ' + timer.to_s)
              timer = nil
              #@events_stream.stop unless @events_stream.nil?
              next
            else
              #     STDERR.puts('PERIOD')
              out <<  {:no_op => true}.to_json#unless lock_timer == true
              out <<  '\n'
            end
          end if timer.nil?

          events_stream = engines_api.container_events_stream
          out.callback {  finialise_events_stream(events_stream, timer)}

          while has_data == true
            #   STDERR.puts('WHILE HAS DATA ' + events_stream.to_s + ':' + events_stream.class.name + ':' + events_stream.rd.class.name + ':' + events_stream.rd.to_s + ':' + events_stream.rd.inspect)
            begin

              bytes = events_stream.rd.read_nonblock(2048)
              #       begin
              next if bytes.nil?
              #       jason_event = ''
              bytes.strip!
              next if bytes.length == 0 || bytes == "\r\n"
              #WHY from JSON if going to send as json ??
              #              #jason_event =  JSON.parse(bytes, :create_additons => true )
              #            rescue  StandardError => e
              #              STDERR.puts('Failed to parse docker events:' + bytes + ':' + e.to_s )
              #              next
              #            end
              #            jason_event = JSON.parse(bytes)
              if out.closed?

                has_data = finialise_events_stream(events_stream, timer)
                STDERR.puts('OUT IS CLOSED but have '  + jason_event.to_s)
                next
              else
                #    STDERR.puts('OUT  EVENTS S ' + jason_event.to_json.to_s )
                out << bytes  #Was JSONjason_event.to_json
                bytes = ''
              end
            rescue IO::WaitReadable
              IO.select([events_stream.rd])
              retry
            rescue IOError => e
              has_data = finialise_events_stream(events_stream, timer)
              #  STDERR.puts('OUT IS IOError  EVENTS S ' + e.to_s + ':' + e.class.name + ':' + e.backtrace.to_s )
              next
            end
          end
        rescue StandardError => e
          STDERR.puts('EVENTS Exception' + e.to_s + ':' + e.class.name + e.backtrace.to_s)
          finialise_events_stream(events_stream, timer)
        end
        #       finialise_events_stream(curr_events_stream)
        #  STDERR.puts('CLOSED  EVENTS S ')
      end
      #  end
    rescue StandardError => e
      #    finialise_events_stream(curr_events_stream)
      STDERR.puts('Stream EVENTS Exception' + e.to_s + e.backtrace.to_s)
    end
    # @events_stream.stop
    #  STDERR.puts('close OF REQUEST TO  /v0/containers/events/stream ')
    # finialise_events_stream( curr_events_stream)
  rescue StandardError =>e
    log_error(request, e)
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
  begin
    r = engines_api.containers_check_and_act
    return_json(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @!endgroup