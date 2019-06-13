module EngineApiEvents
  class EventsStreamWriter
    attr_accessor :rd
    def initialize(system_api)
      @system_api = system_api
      @rd, @wr = IO.pipe
    end

    def write_event(hash)
      unless hash.nil?
        STDERR.puts('write_event ' + hash.to_s)
        @wr.write(hash.to_json)
        @wr.write("\n")
        @wr.flush
      end
      true
    rescue StandardError => e
      p e.to_s
      p e.backtrace.to_s
      STDERR.puts('SHOULD I  CLOSE THIS HERE? TELL ME OH LOG')
    end

    def start
      @rd
    rescue StandardError => e
      p e.to_s
      p e.backtrace.to_s
    end

    def stop
      @system_api.rm_event_listener(self)
      @wr.close #  if @wr.is_open?
      @rd.close #if @rd.is_open?
      STDERR.puts('Event StreamWriter Closed')
    rescue StandardError => e
      p e.to_s
      p e.backtrace.to_s
    end
  end

  def container_events_stream
    stream = EventsStreamWriter.new(@system_api)
    STDERR.puts('new Event StreamWriter')
    @system_api.add_event_listener([stream, 'write_event'.to_sym], 16) # was 16
    stream.start
    stream
  end

end