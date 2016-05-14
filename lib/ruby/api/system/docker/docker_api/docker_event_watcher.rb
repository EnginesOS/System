class DockerEventWatcher  < ErrorsApi

  
  class EventListener
    def initialize(listener, event_mask)
     @object =  listener[0]
     @method = listener[1]
     @event_mask = event_mask
    end
    def hash_name
      return @object.object_id
    end
    
    def trigger(hash)
      return  if  @event_mask != 0 && event_mask(hash) & @event_mask == 0  
      STDERR.puts('fired ' + @object.to_s + ' ' + @method.to_s)
      return @object.method(@method).call(hash)
    rescue StandardError => e    
      STDERR.puts(e.to_s + ':' +  e.backtrace.to_s)
     return e
    end
    
    @@container_event = 1
    @@engine_action  = 2
    @@serivce_action = 4
   # @@container_id
    
    def event_mask(event_hash)
      mask = 0
      mask |= @@container_event if event_hash['Type'] = "container"
      return mask
        
      
      
      #type
      #status
      #action
      
    end
  end
require 'yajl'
require 'net_x/http_unix'
require 'socket'

 def initialize()
 #@system_api = system
 # FIXMe add conntection watcher that re establishes connection asap and continues trying after warngin ....
   @event_listeners = {}
  # add_event_listener([system, :container_event])
 end
 
 def start
   parser = Yajl::Parser.new

   req = Net::HTTP::Get.new('/events')
   client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
   client.continue_timeout=360000
   client.read_timeout=360000
   
  client.request(req) { |resp|
    chunk = ''
    r = ''
   resp.read_body do |chunk|
     hash = parser.parse(chunk) do |hash|
       p hash
       @event_listeners.values.each do |listener |
        
       log_exeception(r) if (r = listener.trigger(hash)).is_a?(StandardError) 
       end
       
     # @system_api.container_event(hash) # if hash.key?('from')     
    end 
   end
 }
   rescue StandardError => e
     log_exception(e,chunk)
end 

def add_event_listener(listener, event_mask = nil)
  event = EventListener.new(listener,event_mask)
  @event_listeners[event.hash_name] = event  
rescue StandardError => e
log_exception(e)
end



  end