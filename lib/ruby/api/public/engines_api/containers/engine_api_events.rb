module EngineApiEvents
  
  class EventsStreamWriter
   def initialize (r,w)
     @rd = r
     @wr = w   
end

def write_event(hash)
  @wr.write(hash)

rescue StandardError => e
  return
  end
  end
    
 def container_events_stream
   rd, wr = IO.pipe
 Thread.new { stream = EventsStreamWriter.new(rd, wr)
   @system_api.add_event_listener([stream,'write_event'.to_sym],16)
   sleep
  }
  return rd
 end
end