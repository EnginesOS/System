module ServiceConfigurations
  def retrieve_service_configuration(config)
    #     c = ConfigurationsApi.new(self)
    #     r = c.
    r= retrieve_service_configuration(config)
    return log_error_mesg('Configration failed ' +  c.last_error.to_s, r) unless r.is_a?(Hash)
    return r
  end

  def get_service_configurations_hashes(service_hash)
    service_manager.get_service_configurations_hashes(service_hash)
  end

  def get_pending_service_configurations_hashes(service_hash)
    service_manager.get_pending_service_configurations_hashes(service_hash)
  end

  def update_service_configuration(service_param)
    # configurator = ConfigurationsApi.new(self)
    return log_error_mesg('Configration failed', @last_error) unless update_service_configuration(service_param)
    return log_error_mesg('Failed to update configuration with', service_manager.last_error) unless check_sm_result(service_manager.update_service_configuration(service_param))
    return true
  end

  def update_service_configuration(service_param)
    return log_error_mesg('Missing Service name',service_param) unless service_param.key?(:service_name)
    service = loadManagedService(service_param[:service_name])
    service_param[:publisher_namespace] = service.publisher_namespace.to_s  # need as saving in config tree
    service_param[:type_path] = service.type_path.to_s
    # setting stopped contianer is ok as call can know the state, used to boot strap a config
    unless service.is_running?
      service_param[:pending]= true
      return true
    end
    if  service_param.key?(:pending)
      service_param.delete(:pending)
    end
    # set config on reunning service
    return log_error_mesg('Service Load error ', last_error.to_s) unless service.is_a?(ManagedService)
    configurator_result =  service.run_configurator(service_param)
    return log_error_mesg('Service configurator erro@core_api.r incorrect result type ', configurator_result.to_s) unless configurator_result.is_a?(Hash)

    return log_error_mesg('Service configurator error ', configurator_result.to_s) unless configurator_result[:result] == 0 || configurator_result[:stderr].start_with?('Warning')
    return true
  end

  def retrieve_service_configuration(service_param)
    return log_error_mesg('Missing service name', service_param) unless service_param.key?(:service_name)
    service = loadManagedService(service_param[:service_name])
    return log_error_mesg('Failed to Load Service', service_param) unless service.is_a?(ManagedService)
    if service.is_running?
      ret_val = service.retrieve_configurator(service_param)
      return log_error_mesg('failed to retrieve configuration', ret_val) unless ret_val.is_a?(Hash)
    else
      return get_service_configuration(service_param)
    end

    return ret_val
  end
end