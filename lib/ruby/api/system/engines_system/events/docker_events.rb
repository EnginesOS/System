require '/opt/engines/lib/ruby/containers/store/cache'

class SystemApi
  require '/opt/engines/lib/ruby/api/system/docker/event_watcher/docker_event_watcher.rb'
  require '/opt/engines/lib/ruby/system/system_config.rb'

  def create_event_listener
    @event_listener_lock = true
    start_docker_event_listener
    @docker_event_listener.add_event_listener(self, :container_event, 16, nil, 0) unless $PROGRAM_NAME.end_with?('system_service.rb')
  end

  class WaitForContainerListener
    def initialize(what, pipe, emask = 16)
      @what = what
      @pipe = pipe
      @mask = emask
    end

    def mask
      @mask
    end

    def read_event(event_hash)
      unless @pipe.closed? || @pipe.nil?
        if event_hash[:status] == @what
          @pipe << 'ok'
          @pipe.close
        end
      else
        raise DockerException.new({:level => :warning, :error_mesg => 'pipe closed'} )
      end
    end
  end

  def wait_for(container, what, timeout)
    r = false
    unless is_aready?(what, container.read_state)
      mask = container_type_mask(container.ctype)
      pipe_in, pipe_out = IO.pipe
      event_listener = WaitForContainerListener.new(what, pipe_out, mask)
      add_event_listener(event_listener, :read_event, event_listener.mask, container.container_name, 100)
      Timeout::timeout(timeout) do
        unless is_aready?(what, container.read_state)
          begin
            d = pipe_in.read
          rescue
          end
        end
        rm_event_listener(event_listener)
        break
      end
    end
    r = true
  rescue Timeout::Error
    STDERR.puts(' Wait for timeout on ' + container.container_name.to_s + ' for ' + what)
    rm_event_listener(event_listener) unless event_listener.nil?
    event_listener = nil
  rescue StandardError => e
    rm_event_listener(event_listener) unless event_listener.nil?
    STDERR.puts(e.to_s)
    STDERR.puts(e.backtrace.to_s)
  ensure
    unless pipe_in.nil?
      pipe_in.close unless pipe_in.closed?
    end
    unless pipe_out.nil?
      pipe_out.close unless pipe_out.closed?
    end
    if r.is_a?(TrueClass)
      true
    else
      is_aready?(what, container.read_state)
    end
  end

  def trigger_event_notification(hash)
    STDERR.puts(" TRIGGER EVENT NOT #{hash}")
    @listeners.each do |m|
      listener = m[1][:listener]
   # listener = m
      unless listener.container_name.nil?
        #WTF just added @docker_event_listener. to match_container
        next unless @docker_event_listener.match_container(hash, listener.container_name)
      end
      begin
        listener.trigger(hash)
      rescue StandardError => e
        SystemDebug.debug(SystemDebug.container_events, hash.to_s + ':' + e.to_s + ':' + e.backtrace.to_s)
      end
    end
  end

  def add_event_listener(object, method, mask, container_id = nil, priority = 200)
    @docker_event_listener.add_event_listener(object, method, mask, container_id, priority)
  end

  def rm_event_listener(listener)
    @docker_event_listener.rm_event_listener(listener)
  end

  private

  def is_aready?(what, statein)
    case what.to_sym
    when statein
      true
    when :stop
      true if statein == :stopped
    when :start
      true if statein == :running
    when :unpause
      true if statein == :running
    when :pause
      true if statein == :paused
    when :create
      true if statein != :nocontainer
    when :destroy
      true if statein == :nocontainer
    else 
      false
    end
    
  end

  def container_event(event_hash)
    unless event_hash.nil? # log_error_mesg('Nil event hash passed to container event','')
      unless event_hash[:id] == 'system'
        if is_engines_container_event?(event_hash)
          inform_container(event_hash)
          case event_hash[:status]
          when 'start', 'oom', 'stop', 'pause', 'unpause', 'create', 'destroy', 'kill', 'die'
            inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
          end
        end
      else
        false
      end
    else
      false
    end
  rescue StandardError => e
    log_exception(e, event_hash)
  end

  def inform_container_tracking(container_name, ctype, event_name)
    c = get_event_container(container_name, ctype)
    c.task_complete(event_name) if c.is_a?(Container::ManagedContainer)
  rescue StandardError =>e
    log_exception(e)
  end

  def get_event_container(container_name, ctype)
    c = cache.container(container_name)
    if c.nil?
      case ctype
      when 'app'
        c = loadManagedEngine(container_name)
      when 'service'
        c = loadManagedService(container_name)
      when  'utility'
        c = loadManagedUtility(container_name)
      else
        log_error_mesg('Failed to find ' + container_name.to_s +  ctype.to_s)
      end
    end
    if c.nil?
      false
    else
      c
    end
  rescue StandardError =>e

    STDERR.puts('FAiled to find ' + container_name.to_s + ' of type ' + ctype.to_s)
    log_exception(e)
  end

  def inform_container(event_hash)
    c = get_event_container(event_hash[:container_name], event_hash[:container_type])
    if c.is_a?(Container::ManagedContainer)
      c.process_container_event(event_hash)
      true
    else
      false
    end
  rescue StandardError => e
    log_exception(e)
  end

  def start_docker_event_listener(listeners = {})
    @listeners = listeners
    @docker_event_listener = DockerEventWatcher.new(listeners)
    @event_listener_thread.exit unless @event_listener_thread.nil?
    @event_listener_thread = Thread.new do
      begin
        while 0 == 0
          @event_listener_thread[:name] = 'docker_event_listener'
          @docker_event_listener.start
         # STDERR.puts( ' EVENT LISTENER THREAD RETURNED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
          @listeners = @docker_event_listener.event_listeners
         # STDERR.puts( 'Starting again with EVENT LISTENER S ' + @listeners.count.to_s)
          @docker_event_listener = DockerEventWatcher.new(@listeners)
       #   STDERR.puts(' EVENT Listener started  post timeout ')
        end
      rescue StandardError => e
        STDERR.puts(' EVENT LISTENER THREAD RETURNED!!!!!!!!!!!' + e.to_s)
      end
      STDERR.puts('Thread ' +  @event_listener_thread.inspect)
    end
  rescue StandardError =>e
    STDERR.puts(e.class.name)
    log_exception(e)
  end

  def is_engines_container_event?(event_hash)
    unless event_hash[:container_type].nil? || event_hash[:container_name].nil?
        ContainerStateFiles.has_config?({c_name: event_hash[:container_name], c_type: event_hash[:container_type]})
    else
      false
    end
  end

  def container_type_mask(ctype)
    mask = 16
    case ctype
    when 'app'
      mask |= 2
    when 'service'
      mask |= 4
    when 'utility'
      mask |= 16384
    end
    mask
  end

  private

  def cache
    Container::Cache.instance
  end
end
