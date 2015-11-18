module ServiceConfigurationActions
  
  def update_service_configuration(service_param)
      return success(service_param[:service_name], service_param[:configurator_name]) if @core_api.update_service_configuration(service_param)
      failed(service_param[:service_name], @core_api.last_error, 'update_service_configuration')
    end
  
    def retrieve_service_configuration(service_param)
      result = @core_api.retrieve_service_configuration(service_param)
      return result if result.is_a?(Hash)
      # FIXME: Gui spats at this failed(service_param[:service_name], @core_api.last_error, 'update_service_configuration')
      return {}
    end

end