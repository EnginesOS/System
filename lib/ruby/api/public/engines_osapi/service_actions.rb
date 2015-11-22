module ServiceActions
  def createService(service_name)
    n_service = getManagedService(service_name)
    return failed(service_name, n_service.last_error, 'Create Service') if n_service.nil?
    return n_service if n_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Create Service') if n_service.create_service
    failed(service_name, n_service.last_error, 'Create Service')
  rescue StandardError => e
    log_exception_and_fail('Create Service', e)
  end

  def recreateService(service_name)
    rc_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Recreate Service') if rc_service.nil?
    return rc_service if rc_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Recreate Service') if rc_service.recreate
    failed(service_name, rc_service.last_error, 'Recreate Service')
  rescue StandardError => e
    return log_exception_and_fail('Recreate Service', e)
  end

  def list_services
    @core_api.list_managed_services
  rescue StandardError => e
    log_exception_and_fail('list_services', e)
  end

  def getManagedServices
    @core_api.getManagedServices
  rescue StandardError => e
    log_exception_and_fail('getManagedServices', e)
  end

  def EnginesOSapi.loadManagedService(service_name, core_api)
    l_service = core_api.loadManagedService(service_name)
    return EnginesOSapi.failed(service_name, core_api.last_error, 'Load Service') unless l_service
    return l_service
  rescue StandardError => e
    EnginesOSapi.log_exception_and_fail('LoadMangedService', e)
  end

  def getManagedService(service_name)
    managed_service = @core_api.loadManagedService(service_name)
    return managed_service if managed_service.is_a?(ManagedService)
    p 'Fail to Load Service configuration:'
    p service_name
    failed(service_name, 'Fail to Load Service configuration:', service_name.to_s)
  rescue StandardError => e
    log_exception_and_fail('getManagedService', e)
  end

  def startService(service_name)
    s_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Start Service') if s_service.nil?
    return s_service if s_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Start Service') if s_service.start_container
    failed(service_name, s_service.last_error, 'Start Service')
  rescue StandardError => e
    log_exception_and_fail('Start Service', e)
  end

  def pauseService(service_name)
    p_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Pause Service') if p_service.nil?
    return p_service if p_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Pause Service') if p_service.pause_container
    failed(service_name, p_service.last_error, 'Pause Service')
  rescue StandardError => e
    log_exception_and_fail('Pause Service', e)
  end

  def unpauseService(service_name)
    u_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Unpause Service') if u_service.nil?
    return u_service if u_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Unpause Service') if u_service.unpause_container
    failed(service_name, u_service.last_error, 'Unpause Service')
  rescue StandardError => e
    log_exception_and_fail('Unpause Service', e)
  end

  def stopService(service_name)
    s_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'Stop Service') if s_service.nil?
    return s_service if s_service.is_a?(EnginesOSapiResult)
    return success(service_name, 'Stop Service') if s_service.stop_container
    failed(service_name, s_service.last_error, 'Stop Service')
  rescue StandardError => e
    log_exception_and_fail('Stop Service', e)
  end

  def list_system_services
    services = []
    services.push('registry')
    return services
  end

  def set_service_hostname_properties(params)
    success(params[:engine_name], 'update service hostname params')
  rescue StandardError => e
    log_exception_and_fail('set_engine_hostname_details ', e)
  end

  def set_service_runtime_properties(params)
    return success(params[:engine_name], 'update service runtime params')
  rescue StandardError => e
    log_exception_and_fail('update service runtime params ', e)
  end

  def get_service_memory_statistics(service_name)
    service = EnginesOSapi.loadManagedService(service_name,@core_api)
    MemoryStatistics.container_memory_stats(service)
  rescue StandardError => e
    log_exception_and_fail('Get Service Memory Statistics', e)
  end

end