class DockerEventWatcher < ErrorsApi
  class EventListener
    require 'yajl'
    attr_accessor :container_name, :event_mask, :priority

    def initialize(listener, event_mask, container_name = nil, priority = 200)
      @object = listener[0]
      @method = listener[1]
      @event_mask = event_mask
      @container_name = container_name
      @priority = priority
    end

    def hash_name
     @object.object_id.to_s
    end

    def trigger(hash)
      mask = EventMask.event_mask(hash)
      SystemDebug.debug(SystemDebug.container_events, 'trigger  mask ' + mask.to_s + ' hash ' + hash.to_s + ' listeners mask:' + @event_mask.to_s + ' result ' )#+ (@event_mask & mask).to_s)
      unless @event_mask & mask == 0
        # skip top
        if mask & 32768 == 0 # @@container_top == 0
          hash[:state] = state_from_status(hash[:status])
          SystemDebug.debug(SystemDebug.container_events, 'fired ' + @object.to_s + ' ' + @method.to_s + ' with ' + hash.to_s)
          @object.method(@method).call(hash)
        end
      end
    rescue StandardError => e
      STDERR.puts(e.to_s + ":\n" + e.backtrace.to_s)
      SystemDebug.debug(SystemDebug.container_events, e.to_s + ':' + e.backtrace.to_s)
      # raise e
    end

    def state_from_status(status)
      case status
      when 'die', 'stop', 'exec'
        status = 'stopped'
      when 'run','start'
        status = 'running'
      when 'pause'
        status = 'paused'
      when 'unpause'
        status = 'running'
      when 'delete','destroy'
        status = 'nocontainer'
      end
      status
    end
  end

  require 'net_x/http_unix'
  require 'socket'
  require_relative 'event_mask.rb'

  def initialize(system, event_listeners = nil )
    @system = system
    # FIXMe add conntection watcher that re establishes connection asap and continues trying after warngin ....
    event_listeners = {} if event_listeners.nil?
    @event_listeners = event_listeners
    # add_event_listener([system, :container_event])
    SystemDebug.debug(SystemDebug.container_events, 'EVENT LISTENER')
  end

  def start
    SystemDebug.debug(SystemDebug.container_events, 'EVENT LISTENER ' + @event_listeners.to_s)
    client = get_client
    client.request(Net::HTTP::Get.new('/events')) do |resp|
      json_part = nil
      resp.read_body do |chunk|
        begin
          SystemDebug.debug(SystemDebug.container_events, chunk.to_s )
          next if chunk.nil?                 
          chunk = json_part.to_s + chunk unless json_part.nil?
          if chunk.match(/.*}[ \n\r]*$/).nil?
            SystemDebug.debug(SystemDebug.container_events, 'DOCKER SENT INCOMPLETE json ' + chunk.to_s )
            json_part = chunk
            next
          else
            json_part = nil
          end
          chunk.sub!(/}[ \n\r]*$/, '}')
          chunk.sub!(/^[ \n\r]*{/,'{')
          #STDERR.puts(' Chunk |' + chunk.to_s + '|')
          parser ||= Yajl::Parser.new({:symbolize_keys => true})
          hash = parser.parse(chunk)                 
          SystemDebug.debug(SystemDebug.container_events, 'got ' + hash.to_s)
          next unless is_valid_docker_event?(hash)          
          #  t = Thread.new {trigger(hash)}
          # t[:name] = 'trigger'
          #need to order requests if use threads
         
          trigger(hash)
        rescue StandardError => e
          STDERR.puts('EXCEPTION Chunk error on docker Event Stream _' + chunk.to_s + '_')
          log_error_mesg('EXCEPTION Chunk error on docker Event Stream _' + chunk.to_s + '_')
          log_exception(e, chunk)
          json_part = ''
          next
        end
      end
      STDERR.puts('END OF read_body')
    end
    log_error_mesg('Restarting docker Event Stream ')
    STDERR.puts('CLOSED docker Event Stream as close')
    client.finish unless client.nil?
    # @system.start_docker_event_listener(@event_listeners)
  rescue Net::ReadTimeout
    log_error_mesg('Restarting docker Event Stream Read Timeout as timeout')
    STDERR.puts('TIMEOUT docker Event Stream as close')
    # @system.start_docker_event_listener(@event_listeners)
    client.finish unless client.nil?
  rescue StandardError => e
    log_exception(e)
    log_error_mesg('Restarting docker Event Stream post exception ')
    STDERR.puts('EXCEPTION docker Event Stream post exception due to ' + e.to_s + ' ' + e.class.name)
    client.finish unless client.nil?
    # @system.start_docker_event_listener(@event_listeners)
  end

  def add_event_listener(listener, event_mask = nil, container_name = nil, priority=200)
    event_listener = EventListener.new(listener, event_mask, container_name, priority)
  @event_listeners[event_listener.hash_name] = 
  { listener: event_listener , 
    priority: event_listener.priority}
  
    STDERR.puts('ADDED listenter ' + listener.class.name + ' Now have ' + @event_listeners.to_s + ' Listeners ')
    SystemDebug.debug(SystemDebug.container_events, 'ADDED listenter ' + listener.class.name + ' Now have ' + @event_listeners.to_s + ' Listeners ')   
  end

  def rm_event_listener(listener)   
    SystemDebug.debug(SystemDebug.container_events, 'REMOVED listenter ' + listener.class.name + ':' + listener.object_id.to_s)
    @event_listeners.delete(listener.object_id.to_s) if @event_listeners.key?(listener.object_id.to_s)
    STDERR.puts('REMOVED listenter ' + listener.class.name + ':' + listener.object_id.to_s)
  end

  private

  def yparser
    @parser ||= Yajl::Parser.new({:symbolize_keys => true})
    @parser
  end
  
  def get_client
    client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
    client.continue_timeout = 3000
    client.read_timeout = 3000
    client
  end

  def match_container(hash, container_name)
    r = false
    if hash.key?(:Actor)
      if hash[:Actor].key?(:Attributes)
        if hash[:Actor][:Attributes].key?(:container_name)
          r = true if hash[:Actor][:Attributes][:container_name] == container_name
        end
      end
    end
    r
  end

   def is_valid_docker_event?(hash)
     r = false
     STDERR.puts('DOCKER SENT ARRAY') if hash.is_a?(Array) && ! hash.is_a?(Hash)
     STDERR.puts('DOCKER SENT UNKNOWN ' + hash.to_s) unless hash.is_a?(Hash)
     r = true if hash.is_a?(Hash)
     r = false if hash.key?(:from) && hash[:from].length >= 64
     r
   end
     
  def trigger(hash)
     t = @event_listeners.sort_by { |k, v| v[:priority] }
    STDERR.puts('sort_by { |k, v| v[:priority] } ' + t.class.name)

      
 #   @event_listeners.values.each do |listener_hash|
    l = @event_listeners.sort_by { |k, v| v[:priority] }
      l.each do |m|
      listener = m[1][:listener]
      unless listener.container_name.nil?
        next unless match_container(hash, listener.container_name)
      end
      listener.trigger(hash)
    end
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.container_events, hash.to_s + ':' + e.to_s + ':' + e.backtrace.to_s)
    log_exception(e)
  end
end