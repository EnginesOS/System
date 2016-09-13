module EngineApiEvents
  
  class EventsStreamWriter
    attr_accessor :rd
    
   def initialize   (system_api)  
     @system_api = system_api
     
     @rd, @wr = IO.pipe
end

def write_event(hash)

 @wr.write(hash.to_json)
  @wr.write("\n\n")
  @wr.flush
  #@wr.fsync

rescue StandardError => e
  p e.to_s
  p e.backtrace.to_s
  return
  end
  
  def start
    Thread.new {  sleep 5 while @wr.is_open? }
      return @rd
  end
  
  def stop
   
    @system_api.rm_event_listener(self)
   # @wr.close if @wr.is_open?
   # @rd.close if @rd.is_open?
  end
  
  end
    
 def container_events_stream
  
 stream = EventsStreamWriter.new(@system_api )
   @system_api.add_event_listener([stream,'write_event'.to_sym],16)
   stream.start
  return stream
 end
 
end