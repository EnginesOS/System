module Actionators
  def list_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
  #  SystemDebug.debug(SystemDebug.actions,'service_def',service_def)
    #  SystemDebug.debug(SystemDebug.actions,service.container_name,service_def[:actionators])
     unless service_def.is_a?(Hash)
       log_error_mesg('list_actionators not a service def ',service_def)
       return false
  end
    unless service_def.key?(:actionators)
      log_error_mesg('list_actionators no actionators',service_def)
      return  false
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
   return false
    rescue StandardError => e
        log_exception( e,'perform_service_action',service_name,actionator_name,params)
  end
  
end