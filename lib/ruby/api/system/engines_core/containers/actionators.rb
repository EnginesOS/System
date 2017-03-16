module Actionators
  def get_engine_actionator(engine, action)
    @system_api.get_engine_actionator(engine, action)
  end

  def list_engine_actionators(engine)
    @system_api.load_engine_actionators(engine)
  rescue StandardError => e
    log_exception(e,'list_actionators', engine)
  end

  def perform_engine_action(engine, actionator_name, params)
    SystemDebug.debug(SystemDebug.actions, engine, actionator_name,params)
    return engine.perform_action(actionator_name, params) if engine.is_running?
    @last_error = "Engine not running"
    raise EnginesException.new(warning_hash('Engine not running', engine.container_name))
  end

  def list_service_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
    unless service_def.is_a?(Hash)
      raise EnginesException.new(error_hash('list_actionators not a service def ',service_def))

    end
    unless service_def.key?(:actionators)
      raise EnginesException.new(error_hash('list_actionators no actionators',service_def))
    end
    unless service_def[:actionators].is_a?(Array)
      #    SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
      return service_def[:actionators]
    end
    # SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
    service_def[:actionators]
  end

  def perform_service_action(service_name,actionator_name,params)
    SystemDebug.debug(SystemDebug.actions,service_name,actionator_name,params)
    service = loadManagedService(service_name)
    return service.perform_action(actionator_name,params) if service.is_running?
    @last_error = "Service not running"
    EnginesCoreError.new('Service not running',:warning)
  rescue StandardError => e
    log_exception( e,'perform_service_action',service_name,actionator_name,params)
  end

end