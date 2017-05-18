module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/event_watcher/docker_event_watcher.rb'
  require '/opt/engines/lib/ruby/system/system_config.rb'

  def create_event_listener
    @event_listener_lock = true
    @docker_event_listener = start_docker_event_listener
    @docker_event_listener.add_event_listener([self,'container_event'.to_sym],16)
  end

  class WaitForContainerListener
    def initialize(what, pipe)
      @what = what
      @pipe = pipe
    end

    def mask
      16
    end

    def read_event(event_hash)
      STDERR.puts(' WAIT FOR GOT ' + event_hash.to_s )
      
      if event_hash[:status] == @what
        'ok' >> @pipe
      end
    end
  end

  def wait_for(container, what, timeout)

    pipe_in, pipe_out = IO.pipe
    event_listener = WaitForContainerListener.new(what, pipe_out)
    add_event_listener([event_listener, 'read_event'.to_sym], event_listener.mask, container.container_id)
    unless is_aready?(what, container.read_state)
      pipe_in.read
    end
    pipe_in.close
    pipe_out.close
    STDERR.puts(e.to_s)
    STDERR.puts(e.backtrace.to_s)
    rm_event_listener(event_listener)
  rescue StandardError => e
    rm_event_listener(event_listener)
    STDERR.puts(e.to_s)
    STDERR.puts(e.backtrace.to_s)
  end

  def is_aready?(what, statein)
    STDERR.puts(' What ' + what.to_s )
    STDERR.puts(' statein ' + statein.to_s )
    return true if what == statein
    whated = what.to_s + 'ed'
    return true if whated == statein
    return true if what == 'unpause' && statein != 'paused'
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

    inform_container(event_hash[:container_name], event_hash[:container_type], event_hash[:status], event_hash)

    case event_hash[:status]
    when 'start','oom','stop','pause','unpause','create','destroy','killed','die'
      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'oom'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'stop'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'pause'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'unpause'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'create'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'destroy'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'killed'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
      #    when 'die'
      #      inform_container_tracking(event_hash[:container_name], event_hash[:container_type], event_hash[:status])
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
    c.task_complete(event_name) unless c.is_a?(FalseClass)
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
      when   'utility'
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

  def inform_container(container_name, ctype, event_name, event_hash)
    SystemDebug.debug(SystemDebug.container_events, 'recevied inform_container',container_name,event_name)
    c = get_event_container(container_name, ctype)
    return false if c.is_a?(FalseClass)
    SystemDebug.debug(SystemDebug.container_events, 'informing _container',container_name,event_name)
    c.process_container_event(event_name, event_hash)
    SystemDebug.debug(SystemDebug.container_events, 'informed _container',container_name,event_name)
    true
  rescue StandardError =>e
    log_exception(e)
  end

  def start_docker_event_listener(listeners = nil)
    @docker_event_listener = DockerEventWatcher.new(self, listeners)
    @event_listener_thread.exit unless @event_listener_thread.nil?
    @event_listener_thread = Thread.new do
      @docker_event_listener.start
      STDERR.puts( ' EVENT LISTENER THREAD RETURNED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    end
    @docker_event_listener
  rescue StandardError =>e
    log_exception(e)
  end

  def add_event_listener(listener, mask, container_id = nil )
    @docker_event_listener.add_event_listener(listener, mask, container_id )
  end

  def rm_event_listener(listener)
    @docker_event_listener.rm_event_listener(listener)
  end
end