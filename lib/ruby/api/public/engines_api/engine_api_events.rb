module EngineApiEvents
  
  class EventsStreamWriter
   def initialize (w)     
     @wr = w   
end

def write_event(hash)
  STDERR.puts(hash.to_s + ' is a ' + hash.class.name)
  b = @wr.write(hash.to_json)
  @wr.flush
  #@wr.fsync

rescue StandardError => e
  p e.to_s
  p e.backtrace.to_s
  return
  end
  end
    
 def container_events_stream
   rd, wr = IO.pipe
 Thread.new { stream = EventsStreamWriter.new( wr)
   @system_api.add_event_listener([stream,'write_event'.to_sym],16)
   sleep 5 while wr.is_open?
   @system_api.rm_event_listener(stream)
  }
  return rd
 end
end