module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/event_watcher/docker_event_watcher.rb'
  require '/opt/engines/lib/ruby/system/system_config.rb'

  def create_event_listener
    @event_listener_lock = true
    @docker_event_listener = start_docker_event_listener
    @docker_event_listener.add_event_listener([self, 'container_event'.to_sym], 16) unless $PROGRAM_NAME.end_with?('system_service.rb')
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
      unless @pipe.closed?
        STDERR.puts(' WAIT FOR GOT ' + event_hash.to_s )
        if event_hash[:status] == @what
          STDERR.puts('writing OK')
          @pipe << 'ok'
          @pipe.close
        else
          STDERR.puts(' WAIT FOR but waiting on ' + @what.to_s )
        end
      end
    end
  end

  def wait_for(container, what, timeout)
    return true if is_aready?(what, container.read_state)
    event_listener = nil
    mask = 16
    case container.ctype
    when 'container'
      mask |= 2
    when 'service'
      mask |= 4
    when 'utility'
      mask |= 16384
    end
    pipe_in, pipe_out = IO.pipe
    Timeout::timeout(timeout) do
      event_listener = WaitForContainerListener.new(what, pipe_out, mask)
      add_event_listener([event_listener, 'read_event'.to_sym], event_listener.mask, container.container_name)
      unless is_aready?(what, container.read_state)
        # STDERR.puts(' Wait on READ ' + container.container_name.to_s + ' for ' + what )
        begin
          d = pipe_in.read
          puts.STDERR.puts(' READ ' + d.to_s)
        rescue
          puts.STDERR.puts(' READ RESCUE')
        end
      end
      pipe_in.close unless pipe_in.closed?
      rm_event_listener(event_listener)
    end
    true
  rescue Timeout::Error
    STDERR.puts(' Wait for timeout on ' + container.container_name.to_s + ' for ' + what )
    rm_event_listener(event_listener) unless event_listener.nil?
    event_listener = nil
    pipe_in.close
    pipe_out.close
    return true if is_aready?(what, container.read_state) #check for last sec call
    false
  rescue StandardError => e
    rm_event_listener(event_listener)
    STDERR.puts(e.to_s)
    STDERR.puts(e.backtrace.to_s)
    pipe_in.close
    pipe_out.close
    false
  end

  def is_aready?(what, statein)
    #  STDERR.puts(' What ' + what.to_s )
    #  STDERR.puts(' statein ' + statein.to_s )
    return true if what == statein
    return true if what == 'stop' && statein == 'stopped'
    return true if what == 'start' && statein == 'running'
    return true if what == 'unpause' && statein == 'running'
    return true if what == 'pause' && statein == 'paused'
    return true if what == 'create' && statein != 'nocontainer'
    return true if what == 'destroy' && statein == 'nocontainer'
    false
  end

  def fill_in_event_system_values(event_hash)
    if event_hash.key?(:Actor) && event_hash[:Actor][:Attributes].is_a?(Hash)
      event_hash[:container_name] = event_hash[:Actor][:Attributes][:container_name]
      event_hash[:container_type] = event_hash[:Actor][:Attributes][:container_type]
    else
      cn_and_t = @engines_api.container_name_and_type_from_id(event_hash[:id])
      raise EnginesException.new(error_hash('cn_and_t Not an array' + cn_and_t.to_s + ':' +  cn_and_t.class.name)) unless cn_and_t.is_a?(Array)
      event_hash[:container_name] = cn_and_t[0]
      event_hash[:container_type] = cn_and_t[1]
    end
    event_hash
  end

  def container_event(event_hash)
    return if event_hash.nil? # log_error_mesg('Nil event hash passed to container event','')
    r = fill_in_event_system_values(event_hash)
    SystemDebug.debug(SystemDebug.container_events,'2 CONTAINER EVENTS' + event_hash.to_s + ':' + r.to_s)

    return if event_hash[:container_type].nil? || event_hash[:container_name].nil?

    if event_hash[:container_type] == 'service' ||  event_hash[:container_type] == 'system_service'||  event_hash[:container_type] == 'utility'
      # Enable Cold load of service from config.yaml
      #  STDERR.puts( SystemConfig.RunDir + '/' + event_hash[:container_type] + 's/' + event_hash[:container_name] + '/running.yaml')
      return no_container(event_hash) unless File.exist?(SystemConfig.RunDir + '/' + event_hash[:container_type] + 's/' + event_hash[:container_name] + '/config.yaml')
    else
      # engines always have a running.yaml
      #   STDERR.puts(SystemConfig.RunDir.to_s + '/' + event_hash[:container_type].to_s + 's/' + event_hash[:container_name].to_s + '/running.yaml')
      return no_container(event_hash) unless File.exist?(SystemConfig.RunDir + '/' + event_hash[:container_type] + 's/' + event_hash[:container_name] + '/running.yaml')
    end

    inform_container(event_hash)

    case event_hash[:status]
    when 'start', 'oom', 'stop', 'pause', 'unpause', 'create', 'destroy', 'kill', 'die'
      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
    else
      SystemDebug.debug(SystemDebug.container_events, 'Untracked event', event_hash.to_s )
    end

  rescue StandardError => e
    log_exception(e, event_hash)
  end

  def no_container(event_hash)
    SystemDebug.debug(SystemDebug.container_events, 'A NO Managed CONTAINER EVENT')
    #FIXME track non system containers here
    #use to clear post build crash
    #alert if present when not building
    true
  end

  def inform_container_tracking(container_name, ctype, event_name)
    SystemDebug.debug(SystemDebug.container_events, 'inform_container_tracking', container_name, ctype, event_name)
    c = get_event_container(container_name, ctype)
    c.task_complete(event_name) if c.is_a?(ManagedContainer)
    #   inform_container_monitor(container_name, ctype, event_name)
  rescue StandardError =>e
    log_exception(e)
  end

  def get_event_container(container_name, ctype)
    c = container_from_cache(container_name)
    if c.nil?
      case ctype
      when 'container'
        c = loadManagedEngine(container_name)
      when 'service'
        c = loadManagedService(container_name)
      when  'utility'
        c = loadManagedUtility(container_name)
      else
        log_error_mesg('Failed to find ' + container_name.to_s +  ctype.to_s)
      end
    end
    return false if c.nil?
    c
  rescue StandardError =>e
    log_exception(e)
  end

  def inform_container(event_hash)

    SystemDebug.debug(SystemDebug.container_events, 'recevied inform_container', event_hash[:container_name],  event_hash[:status])
    c = get_event_container(event_hash[:container_name], event_hash[:container_type])
    return false unless c.is_a?(ManagedContainer)
    SystemDebug.debug(SystemDebug.container_events, 'informing _container', event_hash[:container_name],  event_hash[:status])
    c.process_container_event(event_hash)
    SystemDebug.debug(SystemDebug.container_events, 'informed _container', event_hash[:container_name],  event_hash[:status])
    true
  rescue StandardError =>e
    log_exception(e)
  end

  def start_docker_event_listener(listeners = nil)
    STDERR.puts( ' Start EVENT LISTENER THREAD !!!!!!!!!!!!!!!!!!!!!!!!!!!!! with ' + listeners.to_s)
    @docker_event_listener = DockerEventWatcher.new(self, listeners)
    @event_listener_thread.exit unless @event_listener_thread.nil?
    @event_listener_thread = Thread.new do
      @docker_event_listener.start
      STDERR.puts( ' EVENT LISTENER THREAD RETURNED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    end
    @event_listener_thread[:name] = 'docker_event_listener'
    @docker_event_listener
  rescue StandardError =>e
    STDERR.puts(e.class.name)
    log_exception(e)
  end

  def add_event_listener(listener, mask, container_id = nil )
    @docker_event_listener.add_event_listener(listener, mask, container_id )
  end

  def rm_event_listener(listener)
    @docker_event_listener.rm_event_listener(listener)
  end
end