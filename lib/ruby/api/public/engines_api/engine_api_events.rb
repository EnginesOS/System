module EngineApiEvents
  
  class EventsStreamWriter
    attr_accessor :rd
    
   def initialize     
     @rd, @wr = IO.pipe
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
  
  def start
    Thread.new {  sleep 5 while @wr.is_open? }
      return @rd
  end
  
  def stop
    @wr.close
    @rd.close
  end
  
  end
    
 def container_events_stream
  
 stream = EventsStreamWriter.new( )
   @system_api.add_event_listener([stream,'write_event'.to_sym],16)
   stream.start
  
  
  return stream
 end
 
end