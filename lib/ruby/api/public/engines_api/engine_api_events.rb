module EngineApiEvents
  class EventsStreamWriter
    attr_accessor :rd
    def initialize(system_api)
      @system_api = system_api

      @rd, @wr = IO.pipe
    end

    def write_event(hash)

      @wr.write(hash.to_json)
      @wr.write("\n\n")
      @wr.flush
      #@wr.fsync
    #  STDERR.puts('WRITE TO EVENT STREAM ' + hash.to_s)
    rescue StandardError => e
      p e.to_s
      p e.backtrace.to_s
      return    end

    def start

   #   STDERR.puts(' START EVENT STREAM')
       @rd
    end

    def stop
  #    STDERR.puts(' STOP EVENT STREAM')
      @system_api.rm_event_listener(self)
      #  @live_thread.terminate unless @live_thread.nil?
      @wr.close #  if @wr.is_open?
      @rd.close #if @rd.is_open?
    end

  end

  def container_events_stream

    stream = EventsStreamWriter.new(@system_api )
    @system_api.add_event_listener([stream,'write_event'.to_sym],16)
 #   STDERR.puts('Calling START EVENT STREAM')
    stream.start
     stream
  end

end