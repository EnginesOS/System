class DockerEventWatcher  < ErrorsApi

  
  class EventListener
  @@container_event = 1
   @@engine_target  = 2
   @@service_target = 4
   @@container_exec = 8
   @@container_action = 16
   @@image_event = 32
   @@container_commit = 64
@@container_delete = 128
 @@service_action = @@container_action | @@service_target
 @@engine_action = @@container_action | @@engine_target
  # @@container_id
 
  
    def initialize(listener, event_mask)
     @object =  listener[0]
     @method = listener[1]
     @event_mask = event_mask
    end
    def hash_name
      return @object.object_id
    end
    
    def trigger(hash)
      mask = event_mask(hash)
      return  if  @event_mask != 0 && mask & @event_mask == 0  
      if mask & @@engine_target      
      hash['container_type'] = 'container'
      hash['container_name'] = hash['from'] if hash.key?('from')
      else
        hash['container_name'] = hash['from'].sub(/engines\//,'') if hash.key?('from')
        hash['container_type'] = 'service'
      end
      
      STDERR.puts('fired ' + @object.to_s + ' ' + @method.to_s + ' with ' + hash.to_s)
      return @object.method(@method).call(hash)
    rescue StandardError => e    
      STDERR.puts(e.to_s + ':' +  e.backtrace.to_s)
     return e
    end
    
 
    
    def event_mask(event_hash)
      mask = 0
      if event_hash['Type'] = 'container'
        mask |= @@container_event
        if event_hash.key?('from')
        if  event_hash['from'].start_with?('engines/')
          mask |= @@service_target
        else
          mask |= @@engine_target
        end
        end
        if event_hash['status'].start_with?('exec')
          mask |= @@container_exec
        elsif event_hash['status'] == 'commit'
          mask |= @@container_commit        
          elseif event_hash['status'] == 'delete'
            mask |= @@container_delete
          else
           mask |= @@container_action

        end
      elsif event_hash['Type'] = 'image'
        mask |= @@image_event
        elsif event_hash['Type'] = 'network'
                mask |= @@network_event                
      end
       
      
       
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