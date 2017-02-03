module SmServiceConfigurations
  def update_service_configuration(config_hash)
    #load service definition and from configurators definition and if saveable save

    service_definition = ServiceDefinitions.software_service_definition(config_hash)
    return log_error_mesg('Missing Service definition file ', config_hash.to_s)  unless service_definition.is_a?(Hash)    
    config_hash[:no_save]  = service_definition[:no_save]
    SystemDebug.debug(SystemDebug.services,:update_service, service_definition)
    return log_error_mesg('Missing Configurators in service definition', config_hash.to_s) unless service_definition.key?(:configurators)
    configurators = service_definition[:configurators]
    return log_error_mesg('Missing Configurator ', config_hash[:configurator_name]) unless configurators.key?(config_hash[:configurator_name].to_sym)
    configurator_definition = configurators[config_hash[:configurator_name].to_sym]
    unless configurator_definition.key?(:no_save) && configurator_definition[:no_save]
      STDERR.puts("sm updating config " + config_hash.to_s)
      return test_registry_result(system_registry_client.update_service_configuration(config_hash))
    else
      return true
    end
  rescue Exception=>e
    log_exception(e)
  end

  #@Returns an Array of Configuration hashes resgistered against the service [String] service_name
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  def get_service_configurations_hashes(service_name)

    t = system_registry_client
    test_registry_result( t.get_service_configurations_hashes(service_name) )
  rescue Exception=>e
    log_exception(e)
  end

  def get_service_configuration(service_name)
    t = system_registry_client
    test_registry_result( t.get_service_configuration(service_name) )
  rescue Exception=>e
    log_exception(e)
  end

  def get_pending_service_configurations_hashes(service_name)
    retval = []
    t = system_registry_client
    hashes = t.get_service_configurations_hashes(service_name)
    return retval unless hashes.is_a?(Array)
    hashes.each do |config|
      retval.push(config) if config.key?(:pending)
    end
    return retval
  rescue Exception=>e
    log_exception(e)
  end
end