module Actionators

  def get_engine_actionator(engine, action)
    return @system_api.get_engine_actionator(engine, action)
  end
  
    def list_engine_actionators(engine)
    return @system_api.load_engine_actionators(engine)
    
      rescue StandardError => e
          log_exception(e,'list_actionators', engine)
    end
    
    def perform_engine_action(engine, actionator_name, params)
      SystemDebug.debug(SystemDebug.actions, engine, actionator_name,params)
    # engine = loadManagedEngine(engine_name)
    return engine.perform_action(actionator_name, params) if engine.is_running?
     @last_error = "Engine not running"
     return  EnginesCoreError.new('Engine not running',:warning)
      rescue StandardError => e
        log_exception( e,'perform_engine_action',engine.container_name,actionator_name,params)
    end
    
  
  def list_service_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
  #  SystemDebug.debug(SystemDebug.actions,'service_def',service_def)
    #  SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators])
     unless service_def.is_a?(Hash)
       return log_error_mesg('list_actionators not a service def ',service_def)

  end
    unless service_def.key?(:actionators)
      return log_error_mesg('list_actionators no actionators',service_def)
    end
     unless service_def[:actionators].is_a?(Array)
       #    SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
       return service_def[:actionators]
     end
    # SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators],service_def)
    return service_def[:actionators]
      
    rescue StandardError => e
        log_exception(e,'list_actionators',service)
  end
  
  def perform_service_action(service_name,actionator_name,params)
    SystemDebug.debug(SystemDebug.actions,service_name,actionator_name,params)
   service = loadManagedService(service_name)
  return service.perform_action(actionator_name,params) if service.is_running?
   @last_error = "Service not running"
    return  EnginesCoreError.new('Service not running',:warning)

    rescue StandardError => e
        log_exception( e,'perform_service_action',service_name,actionator_name,params)
  end
  
end