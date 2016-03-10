module OsApiActionators
  def list_actionators(container)
    return list_service_actionators(container) if container.ctype == 'service'
    return list_engine_actionators(container)

  end

  def list_engine_actionators(engine)
    a = @core_api.list_engine_actionators(engine)
    return a if a.is_a?(Hash)
    return EnginesOSapiResult.failed(@last_error,'list_engines actionators',a)
  rescue StandardError => e
    log_exception_and_fail('list_engines actionators', e)
  end

  def perform_engine_action(engine_name,actionator_name,params)
    result = @core_api.perform_engine_action(engine_name,actionator_name,params)
    return  EnginesOSapiResult.failed('perform_engine_action' + engine_name, result.to_s + ':' + params.to_s + ':' + actionator_name.to_s   ,@core_api.last_error)  if result.start_with?('Failed:')
    return result unless result.is_a?(FalseClass)
    return EnginesOSapiResult.failed('perform_engine_action' + engine_name,params.to_s + ':' + actionator_name.to_s,@core_api.last_error)
  rescue StandardError => e
    log_exception_and_fail('perform_service_action', e)

  end

  def list_service_actionators(service)

    a = @core_api.list_service_actionators(service)
    return a if a.is_a?(Hash)
    return EnginesOSapiResult.failed(@last_error,'list_actionators',a)
  rescue StandardError => e
    log_exception_and_fail('list_actionators', e)
  end

  def perform_service_action(service_name,actionator_name,params)
    result = @core_api.perform_service_action(service_name,actionator_name,params)
    return result unless result.is_a?(FalseClass)
    return  EnginesOSapiResult.failed('perform_service_action' + service_name, result.to_s + ':' + params.to_s + ':' + actionator_name   ,@core_api.last_error)  if result.start_with?('Failed:')
    return EnginesOSapiResult.failed('perform_service_action' + service_name,params.to_s + ':' + actionator_name,@core_api.last_error)
  rescue StandardError => e
    log_exception_and_fail('perform_service_action', e)
  end

end