class ConfigurationsApi <ErrorsApi
  def initialize(core_api)
    @core_api = core_api
  end
  def update_service_configuration(service_param)
      return log_error_mesg('Missing Service name',service_param) unless service_param.key?(:service_name)
        service = @core_api.loadManagedService(service_param[:service_name])
        service_param[:publisher_namespace] = service.publisher_namespace.to_s
        service_param[:type_path] = service.type_path.to_s        
        return log_error_mesg('Service Load error ', last_error.to_s) unless service.is_a(ManagedService)
          configurator_result =  service.run_configurator(service_param)
          return log_error_mesg('Service configurator error ', service.last_error.to_s) unless configurator_result.is_a?(Hash)             
        return log_error_mesg('Service configurator error ', service.last_error.to_s) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')
      return false
    end
    
  def retrieve_service_configuration(service_param)
      return log_error_mesg('Missing service name', service_param) unless service_param.key?(:service_name)
        service = @core_api.loadManagedService(service_param[:service_name])
       return log_error_mesg('Failed to Load Service', service_param) unless service.is_a?(ManagedService)
       ret_val = service.retrieve_configurator(service_param) 
       return log_error_mesg('failed to retrieve configuration') unless ret_val.is_a?(Hash)
       return ret_val
    end  
end