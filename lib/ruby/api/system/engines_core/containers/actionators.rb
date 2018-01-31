module Actionators
  def get_engine_actionator(engine, action)
    @system_api.get_engine_actionator(engine, action)
  end

  def get_service_actionator(service, action)
    @system_api.get_service_actionator(service, action)
  end

  def list_engine_actionators(engine)
    @system_api.load_engine_actionators(engine)
  end

  def perform_engine_action(engine, actionator_name, params)
    SystemDebug.debug(SystemDebug.actions, engine, actionator_name, params)
    actionator = get_engine_actionator(engine, actionator_name)    
    if engine.is_running?
      engine.perform_action(actionator, params)
    else
      raise EnginesException.new(warning_hash('Engine not running', engine.container_name))
    end
  end

  def list_service_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
    unless service_def.is_a?(Hash)
      raise EnginesException.new(error_hash('list_actionators not a service def ', service_def))
    end
    unless service_def.key?(:actionators)
      raise EnginesException.new(warning_hash('list_actionators no actionators', service_def))
    end
  #  unless service_def[:actionators].is_a?(Array)
      #    SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
  #    return service_def[:actionators]
  #  end
    # SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
    service_def[:actionators]
  end

  def perform_service_action(service_name, actionator_name, params)
    SystemDebug.debug(SystemDebug.actions, service_name, actionator_name, params)
    service = loadManagedService(service_name)
    actionator = get_service_actionator(service, actionator_name)
    if service.is_running?
      service.perform_action(actionator, params)
    else
      raise EnginesException.new(warning_hash('Service not running', service.container_name))
    end
  end
  
end