module OsApiActionators
  def list_actionators(service)
a = @core_api.list_actionators(service)
return a if a.is_a?(Hash)
return EnginesOSapiResult.failed(@last_error,'list_actionators',a) 
    rescue StandardError => e
        log_exception_and_fail('list_actionators', e)
  end
  
  def perform_service_action(service_name,actionator_name,params)
   result = @core_api.perform_service_action(service_name,actionator_name,params)
   return result unless result.is_a?(FalseClass)
   return EnginesOSapiResult.failed('perform_service_action' + service_name,params.to_s ,actionator_name,@core_api.last_error)
    rescue StandardError => e
        log_exception_and_fail('perform_service_action', e)
  end
  
end