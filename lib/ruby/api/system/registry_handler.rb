class RegistryHandler < ErrorsApi
  def initialize(system_api)
    @system_api = system_api
    @registry_ip = false
  end

  #  # FIXME: take out or registry_root ip ..
  #  def start
  #    @registry_ip = false
  #    registry_root_ip
  #  end

  def force_registry_restart
    # start in thread in case timeout clobbers
    @registry_ip = false
    log_error_mesg("Forcing registry restart", nil)
    registry_service = @system_api.loadSystemService('registry')
    raise EnginesException.new("PANIC cannot load resgitry service definition", registry_service) unless registry_service.is_a?(SystemService)
    #      restart_thread = Thread.new {
    registry_service.stop_container
    registry_service.start_container
    wait = 0
    while registry_service.is_startup_complete? == false
      sleep 1
      wait += 1
      SystemDebug.debug(SystemDebug.registry,:wait_for_start)
      return force_recreate if wait > 120
    end
    SystemDebug.debug(SystemDebug.registry, :restarted_registry)
    true
  end

  def registry_root_ip
    STDERR.puts( 'Registry IP ' + @registry_ip.to_s)
    return @registry_ip unless @registry_ip.is_a?(FalseClass)
    registry_service = @system_api.loadSystemService('registry') # FIXME: Panic if this fails
    unless registry_service.is_running?
      fix_problem(registry_service)
      sleep 12
      @registry_ip = registry_service.get_ip_str
      force_recreate unless registry_service.is_running?
    end
    @registry_ip = registry_service.get_ip_str
    @registry_ip
  rescue Exception
    @registry_ip = false
    fix_problem(registry_service)
    #FixME need to deal with config.yaml / running.yaml
  end

  def fix_problem(registry_service)
    create_c(registry_service) unless registry_service.has_container?
    unpause_c(registry_service) if registry_service.is_paused?
    start_c(registry_service) if registry_service.is_stopped?
    unless registry_service.is_running?
      @registry_ip = false
      unless registry_service.has_container?
        force_registry_recreate
      else
        force_registry_restart
        raise EnginesException.new('Fatal Unable to Start Registry Service: ', registry_service.last_error)
      end
    end
    wait_for_startup
    SystemDebug.debug(SystemDebug.registry, :registry_is_up)
  rescue Exception
    @registry_ip = false
    force_registry_recreate
  end

  private

  def create_c(reg)
    reg.create_container
    wait_for_startup
  end

  def unpause_c(reg)
    reg.unpause_container
    wait_for_startup
  end

  def start_c(reg)
    reg.start_container
    wait_for_startup
  end

  def wait_for_startup
    while !registry_service.is_startup_complete?
      sleep 1
      wait += 1
      SystemDebug.debug(SystemDebug.registry, :wait_for_start_up)
      break if wait > 5
    end
  end

  def force_recreate
    log_error_mesg("Forcing registry recreate", nil)
    @registry_ip = false
    registry_service = @system_api.loadSystemService('registry')
    return log_error_mesg('Fatal Unable to Start Registry Service: ',registry_service.last_error ) if !registry_service.forced_recreate
    wait = 0
    while !registry_service.is_startup_complete?
      sleep 1
      wait += 1
      SystemDebug.debug(SystemDebug.registry, :recreate_wait)
      return log_error_mesg('Failed to complete startup in 90s') if wait > 90
    end
    true
  end

end
