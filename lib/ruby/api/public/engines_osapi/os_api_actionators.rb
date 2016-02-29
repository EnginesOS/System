module OsApiActionators
  def list_actionators(service)
a = @core_api.list_actionators(service)
return a if a.is_a?(Array)
return EnginesOSapiResult.failed(@last_error,'list_actionators') 
    rescue StandardError => e
        log_exception_and_fail('list_actionators', e)
  end
  
  def perform_service_action(service_name,actionator_name,params)
   result = @core_api.perform_service_action(service_name,actionator_name,params)
   if result[:result] == 0
     return result[:stdout]
   end
   return EnginesOSapiResult.failed('list_actionators' + service_name,params.to_s ,actionator_name,result)
    rescue StandardError => e
        log_exception_and_fail('perform_service_action', e)
  end
  
end