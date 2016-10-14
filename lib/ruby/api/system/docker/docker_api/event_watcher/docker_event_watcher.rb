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
    @@container_kill = 256
    @@container_die = 512
    @@container_event = 1024
    @@container_pull = 2048
    @@build_event = 4096
    @@container_attach  = 8192

    @@service_action = @@container_action | @@service_target
    @@engine_action = @@container_action | @@engine_target

    attr_accessor :container_id, :event_mask
    # @@container_id
    def initialize(listener, event_mask, container_id = nil)
      @object =  listener[0]
      @method = listener[1]
      @event_mask = event_mask
      @container_id = container_id
    end

    def hash_name
      return @object.object_id.to_s
    end

    def trigger(hash)
      mask = event_mask(hash)
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

    def event_mask(event_hash)
      mask = 0
      if event_hash[:Type] = 'container'
        mask |= @@container_event
        if event_hash.key?(:from)
          return  mask |= @@build_event if event_hash[:from].nil?
          return  mask |= @@build_event if event_hash[:from].length == 64
          if event_hash[:from].start_with?('engines/')
            mask |= @@service_target
          else
            mask |= @@engine_target
          end
        end
        return  0  if event_hash[:status].nil?

        if event_hash[:status].start_with?('exec')
          mask |= @@container_exec
        elsif event_hash[:status] == 'delete'
          mask |= @@container_delete
        elsif event_hash[:status] == 'destroy'
          mask |= @@container_delete | @@container_action
        elsif event_hash[:status] == 'commit'
          mask |= @@container_commit
        elsif event_hash[:status] == 'pull'
          mask |= @@container_pull
          #        elsif event_hash['status'] == 'delete'
          #          mask |= @@container_delete
        elsif event_hash[:status] == 'die'
          mask |= @@container_die
        elsif event_hash[:status] == 'kill'
          mask |= @@container_kill
        elsif event_hash[:status] == 'attach'
          mask |= @@container_attach
        else
          mask |= @@container_action
        end
      elsif event_hash[:Type] = 'image'
        mask |= @@image_event
      elsif event_hash[:Type] = 'network'
        mask |= @@network_event
      end

      return mask

    end
  end
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'
require 'json'

  def initialize(system)
    @system = system
    # FIXMe add conntection watcher that re establishes connection asap and continues trying after warngin ....
    @event_listeners = {}
    # add_event_listener([system, :container_event])
    SystemDebug.debug(SystemDebug.container_events,'EVENT LISTENER')
  end

  def start
    parser = Yajl::Parser.new(:symbolize_keys => true)

    req = Net::HTTP::Get.new('/events')
    client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
    client.continue_timeout = 3600
    client.read_timeout = 3600

    client.request(req) do |resp|
      resp.read_body do |chunk|
        begin
          r = ''
          chunk.strip!
          STDERR.puts( ' CHUNK' + chunk )
          # xstrip this pattern out {\"log_file_path\":\"/apache2/access.log\",\"log_type\":\"apache\",\"log_name\":\"Mgmt Access Log\",\"ctype\":\"service\",\"parent_engine\":\"mgmt\"}
         # chunk.sub!(/\{\\\"*\}/,'')
          #FIX ME use stdin
          chunk.sub!(/[{\].*\}/,'')
          parser.parse(chunk) do |hash|
            next unless hash.is_a?(Hash)
            SystemDebug.debug(SystemDebug.container_events,'received '  + hash.to_s)
            if hash.key?(:from) && hash[:from].length >= 64
              SystemDebug.debug(SystemDebug.container_events,'skipped '  + hash.to_s)
              next
            end
            @event_listeners.values.each do |listener|
              unless listener.container_id.nil?
                next unless hash[:id] == listener.container_id
              end
              log_exeception(r) if (r = listener.trigger(hash)).is_a?(StandardError)
              log_error_mesg('Trigger error',r,hash) if r.is_a?(EnginesError)
            end
          end
        
        rescue StandardError => e
          log_error_mesg('Chunk error on docker Event Stream _' + chunk.to_s + '_')
          log_exception(e,chunk)
         # @system.start_docker_event_listener
        end
      end      
    end
    log_error_mesg('Restarting docker Event Stream ')
  STDERR.puts('Restarting docker Event Stream ')
    @system.start_docker_event_listener
  rescue StandardError => e
    log_exception(e)
    log_error_mesg('Restarting docker Event Stream post exception ')
    STDERR.puts('Restarting docker Event Stream post exception')
    @system.start_docker_event_listener
  end

  def add_event_listener(listener, event_mask = nil, container_id = nil)
    event = EventListener.new(listener,event_mask, container_id)
    @event_listeners[event.hash_name] = event
    SystemDebug.debug(SystemDebug.container_events,'ADDED listenter ' + listener.class.name + ' Now have ' + @event_listeners.keys.count.to_s + ' Listeners ')
  rescue StandardError => e
    log_exception(e)
  end

  def rm_event_listener(listener)
    SystemDebug.debug(SystemDebug.container_events,'REMOVED listenter ' + listener.class.name + ':' + listener.object_id.to_s)
    @event_listeners.delete(listener.object_id.to_s) if @event_listeners.key?(listener.object_id.to_s)
  rescue StandardError => e
    log_exception(e)
  end

end