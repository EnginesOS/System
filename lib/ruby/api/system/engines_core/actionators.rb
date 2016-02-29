module Actionators
  def list_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
   
     unless service_def.is_a?(Hash)
       log_error_mesg('list_actionators not a service def ',service_def)
       return false
  end
    unless service_def.key?(:actionators)
      log_error_mesg('list_actionators no actionators',service_def)
      return  false
    end
     unless service_def[:actionators].is_a?(Array)
       return service_def[:actionators]
     end
    SystemDebug.debug(SystemDebug.actions,service,service_def[:actionators],service_def)
    return service_def[:actionators]
      
    rescue StandardError => e
        log_exception_and_fail('list_actionators', e)
  end
  
  def perform_service_action(service_name,actionator_name,params)
    SystemDebug.debug(SystemDebug.actions,service_name,actionator_name,params)
   service =  loadManagedService(service_name)
  return service.perform_action(actionator_name,params) if service.is_running?
   @last_error = "Service no running"
   return false
    rescue StandardError => e
        log_exception_and_fail('perform_service_action', e)
  end
  
end