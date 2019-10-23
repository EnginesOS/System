class ConfiguratidonsApi <ErrorsApi
  def initialize(core_api)
    @core_api = core_api
  end

  def update_service_configuration(service_param)
    raise EnginesException.new(error_hash('Missing Service name', service_param)) unless service_param.key?(:service_name)
    service = @core_api.loadManagedService(service_param[:service_name])
    service_param[:publisher_namespace] = service.publisher_namespace.to_s  # need as saving in config tree
    service_param[:type_path] = service.type_path.to_s
    # setting stopped contianer is ok as call can know the state, used to boot strap a config
    unless service.is_running?
      service_param[:pending] = true
    else
      if service_param.key?(:pending)
        service_param.delete(:pending)
      end
      # set config on reunning service
      configurator_result = service.run_configurator(service_param)
      unless configurator_result.is_a?(Hash)
        configurator_result
      else
        raise EnginesException.new(error_hash('Service configurator error ', configurator_result.to_s)) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')
        true
      end
    end
  end

  def retrieve_service_configuration(service_param)
    raise EnginesException.new(error_hash('Missing service name', service_param)) unless service_param.key?(:service_name)
    service = @core_api.loadManagedService(service_param[:service_name])
    if service.is_running?
      ret_val = service.retrieve_configurator(service_param)
      raise EnginesException.new(error_hash('failed to retrieve configuration', ret_val)) unless ret_val.is_a?(Hash)
      ret_val
    else
      @core_api.retrieve_service_configuration(service_param)
    end
  end
end