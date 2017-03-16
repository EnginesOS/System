class DockerEventWatcher  < ErrorsApi
  class EventListener
    require '/opt/engines/lib/ruby/system/deal_with_json.rb'
    attr_accessor :container_id, :event_mask
    # @@container_id
    def initialize(listener, event_mask, container_id = nil)
      @object =  listener[0]
      @method = listener[1]
      @event_mask = event_mask
      @container_id = container_id
    end

    def hash_name
       @object.object_id.to_s
    end

    def trigger(hash)
      mask = EventMask.event_mask(hash)
      # STDERR.puts('trigger  mask ' + mask.to_s + ' hash ' + hash.to_s + ' listeners mask' + @event_mask.to_s)
      SystemDebug.debug(SystemDebug.container_events,'trigger  mask ' + mask.to_s + ' hash ' + hash.to_s + ' listeners mask' + @event_mask.to_s)
      return  if  @event_mask == 0 || mask & @event_mask == 0
      hash[:state] = state_from_status( hash[:status] )
      SystemDebug.debug(SystemDebug.container_events,'fired ' + @object.to_s + ' ' + @method.to_s + ' with ' + hash.to_s)
      return @object.method(@method).call(hash)
    rescue StandardError => e
      SystemDebug.debug(SystemDebug.container_events,e.to_s + ':' +  e.backtrace.to_s)
      return e
    end

    def state_from_status(status)
      case status
      when 'die'
        return 'stopped'
      when 'stop'
        return 'stopped'
      when 'run'
        return 'running'
      when 'start'
        return 'running'
      when 'pause'
        return 'paused'
      when 'unpause'
        return 'running'
      when 'delete'
        return 'nocontainer'
      when 'destroy'
        return 'nocontainer'
      else
        return status
      end
    end

  end
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'
  require 'json'
  require_relative 'event_mask.rb'

  def initialize(system, event_listeners = nil )
    @system = system
    # FIXMe add conntection watcher that re establishes connection asap and continues trying after warngin ....
    event_listeners = {} if event_listeners.nil?
    @event_listeners = event_listeners
    # add_event_listener([system, :container_event])
    SystemDebug.debug(SystemDebug.container_events,'EVENT LISTENER')
  end

  def connection
    @events_connection = Excon.new('unix:///', :socket => '/var/run/docker.sock',
    :debug_request => true,
    :debug_response => true,
    :persistent => true) if @events_connection.nil?
    @events_connection
  end

  def reopen_connection
    @events_connection.reset
    STDERR.puts(' REOPEN doker.sock connection ')
    @events_connection = Excon.new('unix:///', :socket => '/var/run/docker.sock',
    :debug_request => true,
    :debug_response => true,
    :persistent => true)
  end

#  def nstart
#
#    parser =nil
#    streamer = lambda do |chunk, remaining_bytes, total_bytes|
#      begin
#        r = ''
#        chunk.strip!
#        #   parser = FFI_Yajl::Parser.new({:symbolize_keys => true}) if parser.is_nil?
#        #   STDERR.puts('event  cunk ' + chunk.to_s + chunk.class.name )
#
#        deal_with_json(chunk)
#
#        trigger(hash)
#        #        end
#      rescue StandardError => e
#        log_error_mesg('Chunk error on docker Event Stream _' + chunk.to_s + '_')
#        log_exception(e,chunk)
#        # @system.start_docker_event_listener
#      end
#
#    end
#    connection.request(:read_timeout => 7200,
#    :method => :get,
#    :path => '/events',
#    :response_block => streamer )
#    @events_connection.reset
#
#    log_error_mesg('Restarting docker Event Stream ')
#    #  STDERR.puts('Restarting docker Event Stream as close')
#    @system.start_docker_event_listener(@event_listeners)
#
#  rescue  Excon::Error::Socket => e
#    #    STDERR.puts(' docker socket stream close ')
#    @events_connection.reset
#    @system.start_docker_event_listener(@event_listeners)
#  rescue StandardError => e
#    log_exception(e)
#    log_error_mesg('Restarting docker Event Stream post exception ')
#    #  STDERR.puts('Restarting docker Event Stream post exception due to ' + e.to_s)
#    @events_connection.reset
#    @system.start_docker_event_listener(@event_listeners)
#  end

  def start

    req = Net::HTTP::Get.new('/events')
    client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
    client.continue_timeout = 300
    client.read_timeout = 300
    parser = nil

    client.request(req) do |resp|
      json_part = nil
      resp.read_body do |chunk|
        begin
          # parser = FFI_Yajl::Parser.new({:symbolize_keys => true}) if parser.nil?
          #   STDERR.puts('event  cunk ' + chunk.to_s )
          SystemDebug.debug(SystemDebug.container_events,chunk.to_s )
          next if chunk.nil?
          r = ''
          chunk.gsub!(/\s+$/, '')
          chunk = json_part.to_s + chunk unless json_part.nil?
          unless chunk.end_with?('}')
            SystemDebug.debug(SystemDebug.container_events,'DOCKER SENT INCOMPLETE json ' + chunk.to_s )
            json_part = chunk
            next
          else
            json_part = nil
          #  STDERR.puts('DOCKER SENT COMPLETE json ' + chunk.to_s )
          end 
         # STDERR.puts('DOCKER SENT json ' + chunk.to_s )
          #      hash =  parser.parse(chunk)# do |hash|
          hash =  deal_with_json(chunk)
          next unless hash.is_a?(Hash)
          #  STDERR.puts('trigger' + hash.to_s )
          next if hash.key?(:from) && hash[:from].length >= 64
            SystemDebug.debug(SystemDebug.container_events,'skipped '  + hash.to_s)
          # next
          #end
          trigger(hash)

        rescue StandardError => e
          STDERR.puts('EXCEPTION docker Event Stream as close ' + e.to_s)
          log_error_mesg('Chunk error on docker Event Stream _' + chunk.to_s + '_')
          log_exception(e,chunk)
          json_part = ''
          next
          # @system.start_docker_event_listener
        end
      end
    end
    log_error_mesg('Restarting docker Event Stream ')
     STDERR.puts('CLOSED docker Event Stream as close')
    client.finish unless client.nil?
    @system.start_docker_event_listener(@event_listeners)
  rescue Net::ReadTimeout
    log_error_mesg('Restarting docker Event Stream Read Timeout as timeout')
    STDERR.puts('TIMEOUT docker Event Stream as close')
    client.finish unless client.nil?
    @system.start_docker_event_listener(@event_listeners)
  rescue StandardError => e
    log_exception(e)
    log_error_mesg('Restarting docker Event Stream post exception ')
    STDERR.puts('EXCEPTION docker Event Stream post exception due to ' + e.to_s)
    client.finish unless client.nil?
    @system.start_docker_event_listener(@event_listeners)
  ensure
    @system.start_docker_event_listener(@event_listeners)
  end

  def add_event_listener(listener, event_mask = nil, container_id = nil)
    event = EventListener.new(listener,event_mask, container_id)
    SystemDebug.debug(SystemDebug.container_events,'ADDED listenter ' + listener.class.name + ' Now have ' + @event_listeners.keys.count.to_s + ' Listeners ')
    @event_listeners[event.hash_name] = event
  
  rescue StandardError => e
    log_exception(e)
  end

  def rm_event_listener(listener)
    SystemDebug.debug(SystemDebug.container_events,'REMOVED listenter ' + listener.class.name + ':' + listener.object_id.to_s)
    @event_listeners.delete(listener.object_id.to_s) if @event_listeners.key?(listener.object_id.to_s)
  rescue StandardError => e
    log_exception(e)
  end

  private

  def trigger(hash)
    r = ''
    @event_listeners.values.each do |listener|
      unless listener.container_id.nil?
        #   STDERR.puts('matching ' + listener.container_id.to_s)
        next unless hash[:id] == listener.container_id
      end
      log_exeception(r) if (r = listener.trigger(hash)).is_a?(StandardError)
      log_error_mesg('Trigger error',r,hash) if r.is_a?(EnginesError)
    end
  rescue StandardError => e
    SystemDebug.debug(SystemDebug.container_events,hash.to_s + ':' + e.to_s + ':' +  e.backtrace.to_s)
     log_exception(e)
  end
end