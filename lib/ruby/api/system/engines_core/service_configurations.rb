module ServiceConfigurations
  
  def retrieve_service_configuration(config)
     c = ConfigurationsApi.new(self)
     r = c.retrieve_service_configuration(config)
     return log_error_mesg('Configration failed ' +  c.last_error.to_s, r) unless r.is_a?(Hash)
     return r
   end
 
   def update_service_configuration(service_param)
     configurator = ConfigurationsApi.new(self)
     return log_error_mesg('Configration failed', configurator.last_error) unless configurator.update_service_configuration(service_param)
     return log_error_mesg('Failed to update configuration with', service_manager.last_error) unless check_sm_result(service_manager.update_service_configuration(service_param))
     return true
   end
end