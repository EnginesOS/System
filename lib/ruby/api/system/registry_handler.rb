class RegistryHandler < ErrorsApi
  def initialize
    @registry_ip = false
  end

  def force_registry_restart
    # start in thread in case timeout clobbers
    @registry_ip = false
    log_error_mesg("Forcing registry restart", nil)
    registry_service = system_api.loadSystemService('registry')
    raise EnginesException.new("PANIC cannot load resgitry service definition", registry_service) unless registry_service.is_a?(Container::SystemService)
    #      restart_thread = Thread.new {
    registry_service.stop_container
    registry_service.wait_for('stop', 20)
    registry_service.start_container
    force_registry_recreate unless registry_service.wait_for_startup('start', 30)
  #  SystemDebug.debug(SystemDebug.registry, :restarted_registry)
    true
  end

  def registry_root_ip
#    STDERR.puts( 'Registry IP ' + @registry_ip.to_s)
    if @registry_ip.is_a?(FalseClass)
      registry_service = system_api.loadSystemService('registry') # FIXME: Panic if this fails
      unless registry_service.is_running?
        fix_problem(registry_service)
        @registry_ip = registry_service.get_ip_str
   #     STDERR.puts( 'Registry IP ' + @registry_ip.to_s)
        force_registry_recreate unless registry_service.is_running?
      end
      @registry_ip = registry_service.get_ip_str
    #  STDERR.puts( 'Registry IP ' + @registry_ip.to_s)
    end
    @registry_ip
  rescue Exception
    @registry_ip = false
    fix_problem(registry_service)
    #FixME need to deal with config.yaml / running.yaml
  end

  def fix_problem(registry_service = nil)
   # STDERR.puts('FIX PROBLEMS ')
    registry_service = system_api.loadSystemService('registry') if registry_service.nil?
    registry_service.create_container unless registry_service.has_container?
    registry_service.upause_container if registry_service.is_paused?
    registry_service.start_container if registry_service.is_stopped?
 #   STDERR.puts(' waited 15 for start') unless registry_service.wait_for('start', 15)
    unless registry_service.wait_for_startup(40)
 #     STDERR.puts(' waited 40 for startup  complete')
      @registry_ip = false
      unless registry_service.has_container?
        force_registry_recreate
      else
        force_registry_restart
        raise EnginesException.new('Fatal Unable to Start Registry Service: ', registry_service.last_error)
      end
    end
  #  SystemDebug.debug(SystemDebug.registry, :registry_is_up)
    true
  rescue Exception
    @registry_ip = false
    force_registry_recreate
  end

  private

  def force_registry_recreate
    log_error_mesg("Forcing registry recreate", nil)
    @registry_ip = false
    registry_service = system_api.loadSystemService('registry')
    if registry_service.forced_recreate
      registry_service.wait_for('start', 90)
      unless registry_service.wait_for_startup(30)
     #   SystemDebug.debug(SystemDebug.registry, :recreate_wait)
        log_error_mesg('Failed to complete startup in 90s')
      else
        true
      end
    else
      log_error_mesg('Fatal Unable to recreate Registry Service: ', registry_service.last_error )
    end
  end

  private

  def system_api
    @system_api ||= SystemApi.instance
  end
end
